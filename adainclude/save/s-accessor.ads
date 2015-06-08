pragma Restrictions (No_Elaboration_Code);

with Interfaces;    use Interfaces;
with System.RM46;   use System.RM46;

package System.Accessor is
   type HiLo is record
      Hi : Natural;
      Lo : Natural;
   end record;

   procedure Rmw (Register : in out Word;
                  Hi : Natural;
                  Lo : Natural;
                  Valarg : Unsigned_32);
   procedure Rmw (Register : in out Word;
                  Template : HiLo;
                  Valarg : Unsigned_32);
end System.Accessor;
