package body Accessor is
   procedure Rmw (Register : in out Word;
                  Hi : Natural;
                  Lo : Natural;
                  Valarg : Unsigned_32) is
      Tmp     : Unsigned_32;
      Mask    : Unsigned_32;
      Masklen : Natural;
      Value   : Unsigned_32;
      One     : constant Unsigned_32 := 1;
   begin
      Tmp      := Unsigned_32 (Register);
      Masklen  := (Hi - Lo) + 1;
      Mask     := Shift_Left (One, Masklen) - 1;
      Value    := Valarg and Mask;
      Value    := Shift_Left (Value, Lo);
      Mask     := Shift_Left (Mask, Lo);
      Tmp      := Tmp and not Mask;
      Tmp      := Tmp or Value;
      Register := Word (Tmp);
   end Rmw;

   procedure Rmw (Register : in out Word;
                  Template : HiLo;
                  Valarg : Unsigned_32) is
      Hi      : Natural;
      Lo      : Natural;
      Tmp     : Unsigned_32;
      Mask    : Unsigned_32;
      Masklen : Natural;
      Value   : Unsigned_32;
      One     : constant Unsigned_32 := 1;
   begin
      Hi       := Template.Hi;
      Lo       := Template.Lo;
      Tmp      := Unsigned_32 (Register);
      Masklen  := (Hi - Lo) + 1;
      Mask     := Shift_Left (One, Masklen) - 1;
      Value    := Valarg and Mask;
      Value    := Shift_Left (Value, Lo);
      Mask     := Shift_Left (Mask, Lo);
      Tmp      := Tmp and not Mask;
      Tmp      := Tmp or Value;
      Register := Word (Tmp);
   end Rmw;
end Accessor;
