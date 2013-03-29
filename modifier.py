modifier_name_mask_map = {
    "alphashift" : 1 << 16,
    "shift"      : 1 << 17,
    "control"    : 1 << 18,
    "alternate"  : 1 << 19,
    "command"    : 1 << 20,
    "numericpad" : 1 << 21,
    "help"       : 1 << 22,
    "function"   : 1 << 23,
};

SHIFT_MASK = modifier_name_mask_map["shift"]
ALT_MASK = modifier_name_mask_map["alternate"]
CONTROL_MASK = modifier_name_mask_map["control"]
