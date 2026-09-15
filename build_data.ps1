# Generator script to transform official VEXcode V5 C++ raw archive into PROS-styled documentation

$categories = @(
    @{
        name = "Getting Started"
        pages = @(
            @{ title = "Documentation Home"; isHome = $true; dest = "index.html"; relFromApi = "../../index.html"; relFromRoot = "index.html"; summary = "Introduction and landing page for VEXcode V5 C++ documentation in PROS stylization." }
            @{ title = "API Overview"; isApiIndex = $true; dest = "api/cpp/index.html"; relFromApi = "index.html"; relFromRoot = "api/cpp/index.html"; summary = "Complete index of all V5RC-legal VEXcode V5 C++ classes, devices, and modules." }
        )
    },
    @{
        name = "Actuators & Motors"
        pages = @(
            @{ title = "Motor (11W)"; source = "Motor.html"; dest = "api/cpp/motor.html"; className = "vex::motor"; port = "Smart Port 1-21"; summary = "V5 11W Smart Motor with integrated encoder and current, torque, temperature telemetry." }
            @{ title = "Motor 5.5W"; source = "Motor55.html"; dest = "api/cpp/motor55.html"; className = "vex::motor"; port = "Smart Port 1-21"; summary = "V5 5.5W Smart Motor designed for lightweight mechanisms and compact designs." }
            @{ title = "Motor Group"; source = "MotorGroup.html"; dest = "api/cpp/motorgroup.html"; className = "vex::motor_group"; port = "Multiple Smart Ports"; summary = "Synchronized multi-motor control group for lifts, intakes, and drivetrains." }
            @{ title = "Pneumatics"; source = "Pneumatics.html"; dest = "api/cpp/pneumatics.html"; className = "vex::pneumatics"; port = "Smart Port / 3-Wire"; summary = "V5 Pneumatic control for single-acting and double-acting solenoid valves." }
        )
    },
    @{
        name = "Drivetrain"
        pages = @(
            @{ title = "Drivetrain"; source = "Drivetrain.html"; dest = "api/cpp/drivetrain.html"; className = "vex::drivetrain"; port = "2 or 4 Smart Motors"; summary = "Standard 2-motor or 4-motor differential drivetrain with distance and turn tracking." }
            @{ title = "SmartDrive"; source = "SmartDrive.html"; dest = "api/cpp/smartdrive.html"; className = "vex::smartdrive"; port = "Drivetrain + Inertial"; summary = "Inertial-assisted drivetrain offering precision heading turns and gyro correction." }
        )
    },
    @{
        name = "Brain & Controller"
        pages = @(
            @{ title = "Brain"; source = "Brain/index.html"; dest = "api/cpp/brain.html"; className = "vex::brain"; port = "V5 Brain"; summary = "V5 Brain core device providing access to screen, battery, timer, and SD card." }
            @{ title = "Brain Screen"; source = "Brain/Brain.Screen.html"; dest = "api/cpp/brain_screen.html"; className = "Brain.Screen"; port = "V5 Touchscreen"; summary = "Full-color touchscreen graphics, shape rendering, text printing, and touch events." }
            @{ title = "Brain Battery"; source = "Brain/Brain.Battery.html"; dest = "api/cpp/brain_battery.html"; className = "Brain.Battery"; port = "V5 Battery"; summary = "Battery telemetry including voltage, current draw, temperature, and percentage capacity." }
            @{ title = "Brain SD Card"; source = "Brain/Brain.SDcard.html"; dest = "api/cpp/brain_sdcard.html"; className = "Brain.SDcard"; port = "MicroSD Slot"; summary = "File system access for reading and writing files to the micro-SD card." }
            @{ title = "Timer"; source = "Timer.html"; dest = "api/cpp/timer.html"; className = "vex::timer"; port = "System Timer"; summary = "High-precision timer for elapsed time measurement and benchmarking." }
            @{ title = "Controller"; source = "Controller/index.html"; dest = "api/cpp/controller.html"; className = "vex::controller"; port = "V5 Controller"; summary = "V5 handheld remote controller interface for sticks, buttons, and screen." }
            @{ title = "Controller Axis"; source = "Controller/Controller.Axis.html"; dest = "api/cpp/controller_axis.html"; className = "Controller.Axis"; port = "Joysticks"; summary = "Analog joystick channels (Axis1, Axis2, Axis3, Axis4) with position and callbacks." }
            @{ title = "Controller Button"; source = "Controller/Controller.Button.html"; dest = "api/cpp/controller_button.html"; className = "Controller.Button"; port = "Buttons"; summary = "Digital controller buttons (L1, L2, R1, R2, Up, Down, Left, Right, A, B, X, Y)." }
            @{ title = "Controller Screen"; source = "Controller/Controller.Screen.html"; dest = "api/cpp/controller_screen.html"; className = "Controller.Screen"; port = "LCD Display"; summary = "Handheld controller screen text printing, cursor positioning, and line clearing." }
        )
    },
    @{
        name = "Smart Sensors"
        pages = @(
            @{ title = "Inertial Sensor"; source = "Inertial.html"; dest = "api/cpp/inertial.html"; className = "vex::inertial"; port = "Smart Port 1-21"; summary = "3-axis accelerometer and 3-axis gyroscope with sensor-fusion heading, pitch, roll, and yaw." }
            @{ title = "Optical Sensor"; source = "Optical.html"; dest = "api/cpp/optical.html"; className = "vex::optical"; port = "Smart Port 1-21"; summary = "Ambient light, color hue, proximity, gesture detection, and white LED illumination." }
            @{ title = "Distance Sensor"; source = "Distance.html"; dest = "api/cpp/distance.html"; className = "vex::distance"; port = "Smart Port 1-21"; summary = "Time-of-flight laser distance sensor measuring millimetric range and object velocity." }
            @{ title = "Rotation Sensor"; source = "Rotation.html"; dest = "api/cpp/rotation.html"; className = "vex::rotation"; port = "Smart Port 1-21"; summary = "High-resolution absolute and relative shaft encoder with position and angular velocity." }
            @{ title = "GPS Sensor"; source = "GPS.html"; dest = "api/cpp/gps.html"; className = "vex::gps"; port = "Smart Port 1-21"; summary = "Game Field Positioning System sensor tracking absolute X/Y field coordinates and heading." }
            @{ title = "AI Vision Sensor"; source = "AiVision.html"; dest = "api/cpp/aivision.html"; className = "vex::aivision"; port = "Smart Port 1-21"; summary = "AI-powered vision sensor identifying game objects, AprilTags, and color codes." }
            @{ title = "Vision Sensor"; source = "Vision.html"; dest = "api/cpp/vision.html"; className = "vex::vision"; port = "Smart Port 1-21"; summary = "Color-signature tracking camera detecting game objects, sizes, and coordinates." }
        )
    },
    @{
        name = "3-Wire (ADI) Sensors"
        pages = @(
            @{ title = "TriPort (ADI)"; source = "Triport.html"; dest = "api/cpp/triport.html"; className = "vex::triport"; port = "3-Wire Ports A-H"; summary = "TriPort expander and built-in 3-wire ports for competition-legal 3-wire sensors." }
            @{ title = "Bumper Switch"; source = "Bumper.html"; dest = "api/cpp/bumper.html"; className = "vex::bumper"; port = "3-Wire Port A-H"; summary = "Physical mechanical bumper switch detecting contact and presses." }
            @{ title = "Limit Switch"; source = "Limit.html"; dest = "api/cpp/limit.html"; className = "vex::limit"; port = "3-Wire Port A-H"; summary = "Physical micro-switch limit sensor for mechanical stops." }
            @{ title = "Line Tracker"; source = "Line.html"; dest = "api/cpp/line.html"; className = "vex::line"; port = "3-Wire Port A-H"; summary = "Infrared reflectance sensor detecting field line tape and contrast." }
            @{ title = "Encoder"; source = "Encoder.html"; dest = "api/cpp/encoder.html"; className = "vex::encoder"; port = "3-Wire Ports (Pairs)"; summary = "Optical quadrature shaft encoder using two digital ports for rotation tracking." }
            @{ title = "Potentiometer"; source = "Potentiometer.html"; dest = "api/cpp/potentiometer.html"; className = "vex::potentiometer"; port = "3-Wire Port A-H"; summary = "Analog rotary potentiometer measuring up to 250 degrees of shaft position." }
            @{ title = "Potentiometer V2"; source = "PotentiometerV2.html"; dest = "api/cpp/potentiometer_v2.html"; className = "vex::potentiometerV2"; port = "3-Wire Port A-H"; summary = "V2 330-degree rotary potentiometer with enhanced linearity." }
        )
    },
    @{
        name = "System & Utilities"
        pages = @(
            @{ title = "Competition"; source = "Competition.html"; dest = "api/cpp/competition.html"; className = "vex::competition"; port = "Field Control"; summary = "VEX Competition match controller managing autonomous and driver control routines." }
            @{ title = "Thread & Task"; source = "Thread.html"; dest = "api/cpp/thread.html"; className = "vex::thread"; port = "RTOS Multithreading"; summary = "Multithreading and background task execution, priorities, sleep, and concurrency." }
            @{ title = "Event"; source = "Event.html"; dest = "api/cpp/event.html"; className = "vex::event"; port = "Event Handling"; summary = "Broadcast and callback event dispatcher for asynchronous communication." }
        )
    },
    @{
        name = "Reference"
        pages = @(
            @{ title = "Color"; source = "Color.html"; dest = "api/cpp/color.html"; className = "vex::color"; port = "System Type"; summary = "Color management class for RGB, HSV, web hex codes, and alpha transparency." }
            @{ title = "Enumerated Types & Units"; source = "Enums.html"; dest = "api/cpp/enums.html"; className = "vex::enums"; port = "All Hardware Types"; summary = "Complete reference of all unit types, direction types, brake types, and gear ratios." }
        )
    }
)

Write-Host "V5RC-legal categories loaded: $($categories.Count)"
