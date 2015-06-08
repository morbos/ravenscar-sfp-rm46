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
pragma Restrictions (No_Elaboration_Code);

with System.RM46;
with System.BB.Parameters;
with System.BB.Board_Support;

package System.RM46.Rti is
   pragma Preelaborate;

   type RTI_Counter is record
      RTIFRC          : Word; --  RTI Free Running Counter Register
      RTIUC           : Word; --  RTI Up Counter Register
      RTICPUC         : Word; --  RTI Compare Up Counter Register
      Reserved1       : Word;
      RTICAFRC        : Word; --  RTI Capture Free Running Counter Register
      RTICAUC         : Word; --  RTI Capture Up Counter Register
      Reserved2       : Word;
      Reserved3       : Word;
   end record;

   type RTI_Counter_Range is range 0 .. 1;

   type RTI_Counter_Block is array (RTI_Counter_Range) of RTI_Counter;

   RTI_COUNTER_BLOCK0 : constant RTI_Counter_Range := 0;
   RTI_COUNTER_BLOCK1 : constant RTI_Counter_Range := 1;

   type RTI_Compare is record
      RTICOMP         : Word; --  RTI Compare Register
      RTIUDCP         : Word; --  RTI Update Compare Register
   end record;

   type RTI_Compare_Range is range 0 .. 3;

   type RTI_Compare_Block is array (RTI_Compare_Range) of RTI_Compare;

   type RTI_Registers is record
      RTIGCTRL        : Word; --  RTI Global Control Register 16#00#
      RTITBCTRL       : Word; --  RTI Timebase Control Register 16#04#
      RTICAPCTRL      : Word; --  RTI Capture Control Register 16#08#
      RTICOMPCTRL     : Word; --  RTI Compare Control Register 16#0C#
      RTICNT          : RTI_Counter_Block;
      RTICMP          : RTI_Compare_Block;
      RTITBLCOMP      : Word; --  RTI Timebase Low Compare Register 16#70#
      RTITBHCOMP      : Word; --  RTI Timebase High Compare Register 16#74#
      Reserved1       : Word; --  reserved 16#78#
      Reserved2       : Word; --  reserved 16#7c#
      RTISETINTENA    : Word; --  RTI Set Interrupt Enable Register 16#80#
      RTICLEARINTENA  : Word; --  RTI Clear Interrupt Enable Register 16#84#
      RTIINTFLAG      : Word; --  RTI Interrupt Flag Register 16#88#
      RTIDWDCTRL      : Word; --  Digital Watchdog Control Register 16#90#
      RTIDWDPRLD      : Word; --  Digital Watchdog Preload Register 16#94#
      RTIWDSTATUS     : Word; --  Watchdog Status Register 16#98#
      RTIWDKEY        : Word; --  RTI Watchdog Key Register 16#9C#
      RTIDWDCNTR      : Word; --  RTI Digital Watchdog Down Counter Reg 16#A0#
      RTIWWDRXNCTRL   : Word; --  Digital Windowed Wdg Reaction Ctl Reg 16#A4#
      RTIWWDSIZECTRL  : Word; --  Digital Windowed Wdg Wndw Size Ctl Reg 16#A8#
      RTIINTCLRENABLE : Word; --  RTI Compare Interrupt Clear Enable Reg 16#AC#
      RTICOMP0CLR     : Word; --  RTI Compare 0 Clear Register 16#B0#
      RTICOMP1CLR     : Word; --  RTI Compare 1 Clear Register 16#B4#
      RTICOMP2CLR     : Word; --  RTI Compare 2 Clear Register 16#B8#
      RTICOMP3CLR     : Word; --  RTI Compare 3 Clear Register 16#BC#
   end record;

   RTI : RTI_Registers with Volatile, Address
     => System'To_Address (RTI_Base);

   type Notifications is (RTI_NOTIFICATION_COMPARE0, RTI_NOTIFICATION_COMPARE1,
                          RTI_NOTIFICATION_COMPARE2, RTI_NOTIFICATION_COMPARE3,
                          RTI_NOTIFICATION_TIMEBASE, RTI_NOTIFICATION_COUNTER0,
                          RTI_NOTIFICATION_COUNTER1);
   for Notifications use
     (RTI_NOTIFICATION_COMPARE0 => 0,   -- RTI compare 0 notification
      RTI_NOTIFICATION_COMPARE1 => 1,   -- RTI compare 1 notification
      RTI_NOTIFICATION_COMPARE2 => 2,   -- RTI compare 2 notification
      RTI_NOTIFICATION_COMPARE3 => 3,   -- RTI compare 3 notification
      RTI_NOTIFICATION_TIMEBASE => 16,  -- RTI Timebase notification
      RTI_NOTIFICATION_COUNTER0 => 17,  -- RTI counter 0 overflow notification
      RTI_NOTIFICATION_COUNTER1 => 18); -- RTI counter 1 overflow notification

   procedure RtiStartCounter (Counter : RTI_Counter_Range);

   procedure RtiEnableNotification (Notification : Notifications);

   procedure Rti_Init;

   procedure RtiCounter0Expired;

   function RtiFrc0 return System.BB.Board_Support.Timer_Interval;

end System.RM46.Rti;
