import os
import tkinter as tk
from tkinter import filedialog, messagebox

def strip_fnc_prefix(filename):
    name = os.path.splitext(filename)[0]
    if name.startswith("fnc_"):
        return name[4:]
    return name

def get_sqf_files(folder):
    if not os.path.isdir(folder):
        return []
    return sorted([
        strip_fnc_prefix(f)
        for f in os.listdir(folder)
        if f.lower().endswith(".sqf")
    ])

def generate_xeh_prep(base_path):
    functions_path = os.path.join(base_path, "functions")
    handlers_path = os.path.join(functions_path, "handlers")
    public_path = os.path.join(functions_path, "public")

    handlers = get_sqf_files(handlers_path)
    public = get_sqf_files(public_path)

    if not os.path.isdir(handlers_path) and not os.path.isdir(public_path):
        messagebox.showerror("Error", "No handlers or public folders found.")
        return

    if not handlers and not public:
        messagebox.showerror("Error", "No SQF files found in handlers or public folders.")
        return

    output = []

    # Internal (static block)
    output.append("// Internal dialog functions.")
    output.append("A3C_PREP(cacheGroups);")
    output.append("A3C_PREP(cacheControls);")
    output.append("A3C_PREP(ctrl);")
    output.append("A3C_PREP(groupCtrl);")
    output.append("A3C_PREP(refresh);")
    output.append("A3C_PREP(onLoad);")
    output.append("A3C_PREP(onUnload);")
    output.append("")

    # Handlers
    if handlers:
        output.append("// UI event handlers.")
        for fn in handlers:
            output.append(f"A3C_PREP_SUBDIR(handlers,{fn});")
        output.append("")

    # Public
    if public:
        output.append("// Public entry points.")
        for fn in public:
            output.append(f"A3C_PREP_SUBDIR(public,{fn});")

    final_output = "\n".join(output)

    root.clipboard_clear()
    root.clipboard_append(final_output)
    root.update()

    messagebox.showinfo("Success", "XEH_PREP.hpp content copied to clipboard.")

def select_folder():
    folder = filedialog.askdirectory(title="Select dialog folder (contains /functions)")
    if folder:
        generate_xeh_prep(folder)

# UI
root = tk.Tk()
root.title("XEH_PREP.hpp Generator")
root.geometry("300x120")
root.resizable(False, False)

btn = tk.Button(root, text="Create XEH_PREP.hpp", command=select_folder, height=2)
btn.pack(expand=True, fill="both", padx=20, pady=20)

root.mainloop()