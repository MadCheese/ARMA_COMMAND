/*
    Example public action function.

    Replace this file with a real externally callable dialog action.
    For example:
    - change a setting;
    - execute a dialog-related command;
    - update state and then refresh the dialog.
*/

params ["_arg"];

systemChat format ["Template example action called with: %1", _arg];