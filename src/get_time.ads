with Ada.Calendar;

package get_time
with SPARK_Mode => On
is

   pragma Assertion_Policy (Check);

   subtype new_day_d  is String (1 .. 9);
   subtype new_date_d is String (1 .. 10);
   subtype new_hour_h is String (1 .. 5);
   subtype new_form_f is String (1 .. 29);
   subtype am_pm_form is String (1 .. 2);

   subtype option_use is Positive range 1 .. 2
     with Static_Predicate => option_use in 1 .. 2;

   procedure get_day  (Day  : in out new_day_d)
     with
       Depends => (Day =>+ Ada.Calendar.Clock_Time),
       Global  => (Input => Ada.Calendar.Clock_Time),
       Pre     => (for all M of Day => M in 'o' | 'O'),
       Post    => (for all M of Day => M in 'A' .. 'Z'
                     | 'a' .. 'z' | ' ' | 'O');

   procedure get_date (Date : in out new_date_d)
     with
       Depends => (Date =>+ Ada.Calendar.Clock_Time),
       Global  => (Input => Ada.Calendar.Clock_Time),
       Pre     => (for all M of Date => M = '0'),
       Post    => (for all M of Date => M in '0' .. '9'
                     | '-' | '0');

   procedure get_hour (Hour : in out new_hour_h)
     with
       Depends => (Hour =>+ Ada.Calendar.Clock_Time),
       Global  => (Input => Ada.Calendar.Clock_Time),
       Pre     => (for all M of Hour => M = '0'),
       Post    => (for all M of Hour => M in '0' .. '9'
                     | ':' | '0');

   procedure get_format (Format_Str : in out new_form_f;
                         AAMM_PPMM  : in out am_pm_form;
                         Option     : option_use)
     with
       Global  => (Input => Ada.Calendar.Clock_Time),
       Depends => (Format_Str =>+ (Ada.Calendar.Clock_Time, Option),
                   AAMM_PPMM  =>+ (Ada.Calendar.Clock_Time, Option)),
       Pre     => (for all M in Format_Str'Range => Format_Str (M) = '0')
         and then (for all K in AAMM_PPMM'Range => AAMM_PPMM (K) = '0'),
       Post    =>
         (for all I of Format_Str => I in '0' .. '9'
            | '-' | ' ' | ':' | 'A' .. 'Z' | 'a' .. 'z')
         and then
           (for all I of AAMM_PPMM => I in 'A' | 'M'
              | 'P' | '0');

end get_time;
