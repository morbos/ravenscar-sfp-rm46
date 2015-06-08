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

with Ada.Unchecked_Conversion;
with System.RM46;          use System.RM46;
with Accessor;             use Accessor;
with System.BB.Parameters; use System.BB.Parameters;

package body System.RM46.Rti is
   --  RTIGCTRL defines
   CNT0EN   : constant HiLo := (0, 0);
   CNT1EN   : constant HiLo := (1, 1);
   COS      : constant HiLo := (15, 15);
   NTUSEL   : constant HiLo := (19, 16);
   --  RTITBCTRL
   TBEXT    : constant HiLo := (0, 0);
   INC      : constant HiLo := (1, 1);
   --  RTICAPCTRL
   CAPCNTR0 : constant HiLo := (0, 0);
   CAPCNTR1 : constant HiLo := (1, 1);
   --  RTICOMPCTRL
   COMPSEL0 : constant HiLo := (0, 0);
   COMPSEL1 : constant HiLo := (4, 4);
   COMPSEL2 : constant HiLo := (8, 8);
   COMPSEL3 : constant HiLo := (12, 12);
   --  RTIINTFLAG
   INT0    : constant HiLo := (0, 0);
   INT1    : constant HiLo := (1, 1);
   INT2    : constant HiLo := (2, 2);
   INT3    : constant HiLo := (3, 3);
   TBINT   : constant HiLo := (16, 16);
   OVL0INT : constant HiLo := (17, 17);
   OVL1INT : constant HiLo := (18, 18);

   --  RTICLEARINTENA
   CLEARINT0    : constant HiLo := (0, 0);
   CLEARINT1    : constant HiLo := (1, 1);
   CLEARINT2    : constant HiLo := (2, 2);
   CLEARINT3    : constant HiLo := (3, 3);
   CLEARDMA0    : constant HiLo := (8, 8);
   CLEARDMA1    : constant HiLo := (9, 9);
   CLEARDMA2    : constant HiLo := (10, 10);
   CLEARDMA3    : constant HiLo := (11, 11);
   CLEARTBINT   : constant HiLo := (16, 16);
   CLEAROVL0INT : constant HiLo := (17, 17);
   CLEAROVL1INT : constant HiLo := (18, 18);

   procedure Rti_Init is
   begin
      --  Setup NTU source, debug options and disable both counter blocks
      Rmw (RTI.RTIGCTRL, CNT0EN, 0);
      Rmw (RTI.RTIGCTRL, CNT1EN, 0);
      Rmw (RTI.RTIGCTRL, COS, 0);
      Rmw (RTI.RTIGCTRL, NTUSEL, 16#a#);

      --  Setup timebase for free running counter 0
      Rmw (RTI.RTITBCTRL, TBEXT, 0);
      Rmw (RTI.RTITBCTRL, INC, 0);

      --  Enable/Disable capture event sources for both counter blocks
      Rmw (RTI.RTICAPCTRL, CAPCNTR0, 0);
      Rmw (RTI.RTICAPCTRL, CAPCNTR1, 0);

      --  Setup input source compare 0-3
      Rmw (RTI.RTICOMPCTRL, COMPSEL0, 0);
      Rmw (RTI.RTICOMPCTRL, COMPSEL1, 0);
      Rmw (RTI.RTICOMPCTRL, COMPSEL2, 1);
      Rmw (RTI.RTICOMPCTRL, COMPSEL3, 1);

      for I in RTI.RTICNT'Range loop
         --  Reset up counter
         Rmw (RTI.RTICNT (I).RTIUC, 31, 0, 0);

         --  Reset free running counter
         Rmw (RTI.RTICNT (I).RTIFRC, 31, 0, 0);

         --  Setup up counter compare value
         --    - 0x00000000: Divide by 2^32
         --    - 0x00000001-0xFFFFFFFF: Divide by (CPUCx + 1)
         --
         Rmw (RTI.RTICNT (I).RTICPUC, 31, 0, 10);
      end loop;

      --  Setup compare 0 value. This value is compared with selected
      --  free running counter.
      --  vvvvvvvv -> 1msec
      Rmw (RTI.RTICMP (0).RTICOMP, 31, 0, 10000);

      --  Setup update compare 0 value. This value is added to the compare 0
      --  value on each compare match.
      Rmw (RTI.RTICMP (0).RTIUDCP, 31, 0, 1000000);

      --  Setup compare 1 value. This value is compared with selected free
      --  running counter.
      Rmw (RTI.RTICMP (1).RTICOMP, 31, 0, 50000);

      --  Setup update compare 1 value. This value is added to the compare 1
      --  value on each compare match.
      Rmw (RTI.RTICMP (1).RTIUDCP, 31, 0, 50000);

      --  Setup compare 2 value. This value is compared with selected free
      --  running counter.
      Rmw (RTI.RTICMP (2).RTICOMP, 31, 0, 80000);

      --  Setup update compare 2 value. This value is added to the compare 2
      --  value on each compare match.
      Rmw (RTI.RTICMP (2).RTIUDCP, 31, 0, 80000);

      --  Setup compare 3 value. This value is compared with selected
      --  free running counter.
      Rmw (RTI.RTICMP (3).RTICOMP, 31, 0, 100000);

      --  Setup update compare 3 value. This value is added to the compare 3
      --  value on each compare match.
      Rmw (RTI.RTICMP (3).RTIUDCP, 31, 0, 100000);

      --  Clear all pending interrupts
      Rmw (RTI.RTIINTFLAG, INT0, 1);
      Rmw (RTI.RTIINTFLAG, INT1, 1);
      Rmw (RTI.RTIINTFLAG, INT2, 1);
      Rmw (RTI.RTIINTFLAG, INT3, 1);
      Rmw (RTI.RTIINTFLAG, TBINT, 1);
      Rmw (RTI.RTIINTFLAG, OVL0INT, 1);
      Rmw (RTI.RTIINTFLAG, OVL1INT, 1);

      Rmw (RTI.RTICLEARINTENA, CLEARINT0, 1);
      Rmw (RTI.RTICLEARINTENA, CLEARINT1, 1);
      Rmw (RTI.RTICLEARINTENA, CLEARINT2, 1);
      Rmw (RTI.RTICLEARINTENA, CLEARINT3, 1);
      Rmw (RTI.RTICLEARINTENA, CLEARDMA0, 1);
      Rmw (RTI.RTICLEARINTENA, CLEARDMA1, 1);
      Rmw (RTI.RTICLEARINTENA, CLEARDMA2, 1);
      Rmw (RTI.RTICLEARINTENA, CLEARDMA3, 1);
      Rmw (RTI.RTICLEARINTENA, CLEARTBINT, 1);
      Rmw (RTI.RTICLEARINTENA, CLEAROVL0INT, 1);
      Rmw (RTI.RTICLEARINTENA, CLEAROVL1INT, 1);

   end Rti_Init;

   procedure RtiStartCounter (Counter : RTI_Counter_Range) is
      Bitpos : Bits32;
   begin
      Bitpos := Bits32 (Counter);
      --  Setup NTU source, debug options and disable both counter blocks
      Rmw (RTI.RTIGCTRL, Bitpos, Bitpos, 1);
   end RtiStartCounter;

   function As_Bits32 is new Ada.Unchecked_Conversion
     (Source => Notifications, Target => Bits32);

   procedure RtiEnableNotification (Notification : Notifications) is
      Bitpos : Bits32;
   begin
      Bitpos := As_Bits32 (Notification);
      Rmw (RTI.RTIINTFLAG, Bitpos, Bitpos, 1);
      Rmw (RTI.RTISETINTENA, Bitpos, Bitpos, 1);

   end RtiEnableNotification;

   procedure RtiCounter0Expired is
   begin
      Rmw (RTI.RTIINTFLAG, 0, 0, 1);
   end RtiCounter0Expired;

   function RtiFrc0 return System.BB.Board_Support.Timer_Interval is
   begin
      return System.BB.Board_Support.Timer_Interval (RTI.RTICNT (0).RTIFRC);
   end RtiFrc0;

end System.RM46.Rti;
