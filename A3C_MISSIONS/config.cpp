class CfgPatches {
    class A3C_Showcases {
        requiredAddons[] = {"A3_Data_F"};
        units[] = {};
        weapons[] = {};
        author = "Mad_Cheese";
        authorUrl = "";
    };
};

// class CfgMissions {
// 	class Showcases {
// 		//displayName = "A3C SHOWCASES";
// 		briefingName = "A3C SHOWCASES";
// 		overview = "";
// 		class A3C_Showcase {
// 		    briefingName = "ARMA COMMAND - INTRODUCTION cpp";
// 			directory = "A3C_missions\showcases\A3C_INTRODUCTION.Malden"; // Path to the mission PBO without the .pbo extension;
// 		};
// 	};
// };

class CfgMissions {
    class Showcases {
        class A3C_Showcases { // This is a new nested class
            briefingName = "A3C SHOWCASES";

            class A3C_Showcase {
                briefingName = "ARMA COMMAND - INTRODUCTION";
                directory = "A3C_missions\showcases\A3C_INTRODUCTION.Malden";
            };
            // Additional showcases can be nested here
        };
    };
};


