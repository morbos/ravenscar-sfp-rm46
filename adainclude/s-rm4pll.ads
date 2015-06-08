with System.RM46;
with Accessor; --  use Accessor;

package System.RM46.Pll is
   pragma Preelaborate;

   --  Local Subprograms
   procedure Reset (Register : in out Word; Mask : Word);
   procedure Set (Register : in out Word; Mask : Word);
   procedure Initialize_Clocks;
   procedure Pll_Spinup;
   pragma Unreferenced (Set);
   pragma Unreferenced (Reset);

end System.RM46.Pll;
