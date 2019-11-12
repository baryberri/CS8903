typedef enum {
    Init,
    Load,
    Compute
} PE_State deriving (
    Bits,
    Eq
);
