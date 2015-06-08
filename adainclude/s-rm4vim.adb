------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--          Copyright (C) 2012-2013, Free Software Foundation, Inc.         --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

pragma Ada_2012; -- To work around pre-commit check?
pragma Restrictions (No_Elaboration_Code);

with System.Machine_Code;
with System.RM46;          use System.RM46;
with Accessor;             use Accessor;
with System.BB.Parameters; use System.BB.Parameters;

package body System.RM46.Vim is
   --   use CPU_Primitives, Interrupts, Machine_Code;
   use Machine_Code;

   --  You can get to this handler if an interrupt comes in on a slot
   --  you are not prepared to handle.
   procedure Phantom_Handler is
   begin
      loop
         null;
      end loop;
   end Phantom_Handler;

   procedure Vim_Init is
--      Result : Word;
   begin
      --  Preload all slots with the phantom handler. Subsequently,
      --  slots are replaced selectively as needed with real handlers.
      for I in VIM_RAM'Range loop
         VIM_RAM (I) := Phantom_Handler'Access;
      end loop;

      --  Enable the VIC. Per the TRM its disabled at PoR. When disabled,
      --  IRQ&FIQ service falls back to legacy functionality and the 0 index
      --  returned by the VIC will go to the Phantom handler.

      --  VIC enable code
      --  Off vvvv for now as legacy seems better for now
--      Asm ("mrc p15,#0,%0,c1,c0,#0",
--           Outputs => Word'Asm_Output ("=&r", Result),
--           Volatile => True);

--      Result := Result or 16#1000000#; --  Enable the VIC

--      Asm ("mcr p15,#0,%0,c1,c0,#0",
--           Inputs => Word'Asm_Input ("r", Result),
--           Volatile => True);

      Rmw (VIMp.REQENASET0, 2, 2, 1);  --  RTI COUNTER0 (CHAN2)

   end Vim_Init;

--   function Vim_IrqIndex return System.BB.Parameters.Vector_Id is
--   begin
--
--      return System.BB.Parameters.Vector_Id (VIMp.IRQINDEX);
--
--   end Vim_IrqIndex;

end System.RM46.Vim;
