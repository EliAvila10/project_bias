with Ada.Calendar.Formatting;
with Ada.Calendar.Time_Zones;
with Ada.Strings;
with Ada.Strings.Fixed;

package body get_time
with SPARK_Mode => On
is

   pragma Warnings (Off);

   procedure To_Lower_Internal (Itm : in out String) with
     Pre => (Itm'First = 1) and then (Itm'Length >= 6)
     and then (Itm'Last = Itm'Length) and then (Itm'Length <= 9),
     Post => (for all I in Itm'First + 1 .. Itm'Last =>
                (if Character'Pos (Itm'Old (I)) in 65 .. 90
                     then Character'Pos (Itm (I))
                 = Character'Pos (Itm'Old (I)) + 32
                   else Itm (I) = Itm'Old (I))),
     Global => null,
     Depends => (Itm => Itm)
   is

      subtype convt is Positive range 65 .. 90
        with Static_Predicate => convt in 65 .. 90;

      subtype rest is Positive range 97 .. 122
        with Static_Predicate => rest in 97 .. 122;

      convert : convt := 65;
      restret : rest;

      bits_tw     : constant Positive := 32;
      Itm_Inicial : constant String   := Itm;

   begin

      for I in Itm'First + 1 .. Itm'Last loop

         pragma Loop_Variant   (Increases => I);
         pragma Loop_Invariant (I in Itm'First .. Itm'Last);

         pragma Loop_Invariant
           (for all K in Itm'First + 1 .. I - 1 =>
              (if Character'Pos (Itm_Inicial (K)) in convt
               then Character'Pos
                 (Itm (K)) = Character'Pos (Itm_Inicial (K)) + bits_tw
               else Itm (K) = Itm_Inicial (K)));

         pragma Loop_Invariant (for all K in I .. Itm'Last =>
                                  Itm (K) = Itm_Inicial (K));

         if Character'Pos (Itm (I)) in convt then

            case convert is
               when convt =>
                  convert := Character'Pos (Itm (I));
                  restret := convert + bits_tw;

                  if restret in rest then
                     Itm (I)  := Character'Val (restret);
                  end if;
            end case;

         end if;

      end loop;

   end To_Lower_Internal;

   ----

   function Get_Day_Valid (Item : String) return Boolean is
     ((for all chars in Item'First .. Item'Last
      => Item (chars) in 'A' .. 'Z' | 'a' .. 'z' | ' ' .. ' '))
     with
       Pre => (Item'First = 1) and then (Item'Length >= 6)
     and then (Item'Length <= 9) and then (Item'Last = Item'Length),
     Post => (if Get_Day_Valid'Result then
                (for all chars in Item'First .. Item'Last
                 => Item (chars) in 'A' .. 'Z' | 'a' .. 'z' | ' ' .. ' ')),
     Global => null;

   ----

   function Get_Date_Valid (Item : new_date_d) return Boolean is
     ((for all chars in Item'First .. Item'Last
      => Item (chars) in '0' .. '9' | '-' .. '-'))
     with
       Global => null,
       Post   => (if Get_Date_Valid'Result then
                    (for all chars in Item'First .. Item'Last
                     => Item (chars) in '0' .. '9' | '-' .. '-'));
   ----

   function Get_Hour_Valid (Item : new_hour_h) return Boolean is
     ((for all chars in Item'First .. Item'Last
      => Item (chars) in '0' .. '9' | ':' .. ':'))
     with
       Global => null,
       Post   => (if Get_Hour_Valid'Result then
                    (for all chars in Item'First .. Item'Last
                     => Item (chars) in '0' .. '9' | ':' .. ':'));
   ----

   function Get_Hour_Valid2 (Item : am_pm_form) return Boolean is
     ((for all chars in Item'First .. Item'Last
      => Item (chars) in '0' .. '9'))
     with
       Global => null,
       Post   => (if Get_Hour_Valid2'Result then
                    (for all chars in Item'First .. Item'Last
                     => Item (chars) in '0' .. '9'));

   ----

   function Get_Format_Valid (Item : new_form_f) return Boolean is
     ((for all chars in Item'First .. Item'Last
      => Item (chars) in '0' .. '9' | '-' .. '-'
        | ' ' .. ' ' | ':' .. ':' | 'A' .. 'Z' | 'a' .. 'z'))
       with
         Global => null,
         Post   => (if Get_Format_Valid'Result then
                      (for all chars in Item'First .. Item'Last
                       => Item (chars) in '0' .. '9' | '-' .. '-'
                         | ' ' .. ' ' | ':' .. ':' | 'A' .. 'Z' | 'a' .. 'z'));

   ----

   procedure get_day (Day : in out new_day_d) is

      pragma Warnings (off, "no Global contract available");
      pragma Warnings (off, "assuming ""*"" has no effect on global items");

      A_Clock      : constant Ada.Calendar.Time := Ada.Calendar.Clock;
      A_Day_Name   : constant Ada.Calendar.Formatting.Day_Name
        :=  Ada.Calendar.Formatting.Day_Of_Week (A_Clock);

      New_Day_Name : constant String := A_Day_Name'Image;

      type days is array (1 .. 7) of String (1 .. 9);
      New_Day      : constant days := (1 => "MONDAY   ",
                                       2 => "TUESDAY  ",
                                       3 => "WEDNESDAY",
                                       4 => "THURSDAY ",
                                       5 => "FRIDAY   ",
                                       6 => "SATURDAY ",
                                       7 => "SUNDAY   ");

   begin

      if New_Day_Name'Length in 6 .. 9 then

         if Get_Day_Valid (Item => New_Day_Name) then

            look_day :
            for I in days'First .. days'Last loop

               if New_Day_Name =
                 Ada.Strings.Fixed.Trim (New_Day (I), Ada.Strings.Right)
               then

                  custom :
                  declare
                     to_low : String (1 .. 9) := (others => '0');
                  begin
                     to_low (1 .. 9) := New_Day (I);
                     To_Lower_Internal (Itm => to_low);

                     if Get_Day_Valid (Item => to_low) then
                        Day (Day'First .. Day'Last) := to_low;
                        return;
                     else
                        exit look_day;
                     end if;

                  end custom;

               end if; -- JMCP

            end loop look_day;

         end if; -- GDV

      end if; -- NDN

   end get_day;

   ----

   procedure get_date (Date : in out new_date_d) is

      pragma Warnings (off, "no Global contract available");
      pragma Warnings (off, "assuming ""*"" has no effect on global items");

      Now            : constant Ada.Calendar.Time := Ada.Calendar.Clock;
      My_Zone        : constant Ada.Calendar.Time_Zones.Time_Offset
        := Ada.Calendar.Time_Zones.Local_Time_Offset (Now);

      Full_Date_Str  : constant String := Ada.Calendar.Formatting.Image
        (Date => Now, Time_Zone => My_Zone);

   begin

      if Full_Date_Str'Length >= 10 then

         declare
            Joint : constant new_date_d :=
              Full_Date_Str (Full_Date_Str'First .. Full_Date_Str'First + 9);
         begin

            if Get_Date_Valid (Item => Joint) then
               Date := Joint (Joint'First .. Joint'First + Joint'Length - 1);
               return;
            end if;

         end;

      end if;

   end get_date;

   ----

   procedure get_hour (Hour : in out new_hour_h) is

      pragma Warnings (off, "no Global contract available");
      pragma Warnings (off, "assuming ""*"" has no effect on global items");

      Now            : constant Ada.Calendar.Time := Ada.Calendar.Clock;
      My_Zone        : constant Ada.Calendar.Time_Zones.Time_Offset
        := Ada.Calendar.Time_Zones.Local_Time_Offset (Now);

      Full_Hour_Str  : constant String := Ada.Calendar.Formatting.Image
        (Date => Now, Time_Zone => My_Zone);

      type tw_form is array (1 .. 12) of String (1 .. 2);
      tw             : constant tw_form :=
        (1  => "01", 2  => "02", 3  => "03", 4  => "04", 5  => "05",
         6  => "06", 7  => "07", 8  => "08", 9  => "09", 10 => "10",
         11 => "11", 12 => "12");
   begin

      if Full_Hour_Str'Length = 19 then -- 1

         dec1  :
         declare
            Joint : String (1 .. 5) :=
              Full_Hour_Str
                (Full_Hour_Str'First + 11 .. Full_Hour_Str'Last - 3);

         begin

            if Get_Hour_Valid2 (Item => Joint (1 .. 2)) then -- 2

               dec2 :
               declare

                  Dec  : constant Natural
                    := Character'Pos (Joint (1)) - Character'Pos ('0');
                  Uni  : constant Natural
                    := Character'Pos (Joint (2)) - Character'Pos ('0');

                  Tw_W    : Natural := (Dec * 10) + Uni;
               begin

                  if Tw_W in 13 .. 23 then -- 3
                     Tw_W := Tw_W - 12;
                     Joint (1 .. 2) := tw (Tw_W);

                     if Get_Hour_Valid (Item => Joint) then
                        Hour :=
                          Joint
                            (Joint'First .. Joint'First + Joint'Length - 1);
                        return;
                     end if;

                  elsif Tw_W = 0 then
                     Joint (1 .. 2) := tw (12);

                     if Get_Hour_Valid (Item => Joint) then
                        Hour :=
                          Joint
                            (Joint'First .. Joint'First + Joint'Length - 1);
                        return;
                     end if;

                  else

                     if Get_Hour_Valid (Item => Joint) then
                        Hour :=
                          Joint
                            (Joint'First .. Joint'First + Joint'Length - 1);
                        return;
                     end if;

                  end if; -- 3

               end dec2;

            end if; -- 2

         end dec1;

      end if; -- 1

   end get_hour;

   ----

   procedure get_format (Format_Str : in out new_form_f;
                         AAMM_PPMM  : in out am_pm_form;
                         Option     : option_use)
   is
      pragma Warnings (off, "no Global contract available");
      pragma Warnings (off, "assuming ""*"" has no effect on global items");

      Now        : constant Ada.Calendar.Time := Ada.Calendar.Clock;
      My_Zone    : constant Ada.Calendar.Time_Zones.Time_Offset :=
        Ada.Calendar.Time_Zones.UTC_Time_Offset (Now);
      Designator : constant Ada.Calendar.Formatting.Hour_Number
        := Ada.Calendar.Formatting.Hour (Date => Now, Time_Zone => My_Zone);

      A : constant String (1 .. 2) := "AM";
      P : constant String (1 .. 2) := "PM";

      function mid return String
        with Pre => (Designator in 0 .. 23),
        Post => (if Designator <= 11 then mid'Result = A
                   else mid'Result = P)
      is
      begin
         return String'(if Designator <= 11 then A else P);
      end mid;

      AM_PM : constant String (1 .. 2) := mid;

      Space : constant String := " ";
      Day   : new_day_d  := (others => 'O');
      Year  : new_date_d := (others => '0');
      Hour  : new_hour_h := (others => '0');
      Join  : new_form_f;
   begin

      case Option is
         when 1 =>
            get_day (Day => Day);
            get_date (Date => Year);
            get_hour (Hour => Hour);

            Join       := Year & Space & Day & Space & Hour & Space & AM_PM;

            if Get_Format_Valid (Item => Join) then
               Format_Str := Join;
            end if;

         when 2 =>
            AAMM_PPMM := AM_PM;
      end case;

   end get_format;

end get_time;
