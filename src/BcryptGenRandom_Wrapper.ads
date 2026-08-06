with System;
with Interfaces;
with Interfaces.C;
with Ada.Real_Time;

with Windows_Data_Types;

package BcryptGenRandom_Wrapper with SPARK_Mode => On is

   use System;
   use Interfaces.C;
   use Interfaces;
   use Ada.Real_Time;

   use Windows_Data_Types;

   pragma Assertion_Policy (Check);

   procedure BcryptGenRandom_Public
     (Buffer : in out BUFFER_RNG;
      Status : in out NTSTATUS)
     with
       Global  => (Input => Ada.Real_Time.Clock_Time),
       Depends => (Buffer => Buffer,
                   Status => (Buffer, Status),
                   null   => Ada.Real_Time.Clock_Time),
       Pre     => Buffer'First = 0
       and then Buffer'Length >= 32
       and then Status /= 0,
       Post    => (if Status = 0 then
                     Buffer /= (Buffer'Range => 0)
                       else
                         Buffer = (Buffer'Range => 0));
private

   pragma Linker_Options ("-lbcrypt");

   Interval          : constant Ada.Real_Time.Time_Span
     := Milliseconds (MS => 2_000);
   Retry             : Ada.Real_Time.Time
     := Ada.Real_Time.Clock;

   BCRYPT_ALG_HANDLE               : constant HANDLE
     := System.Null_Address;
   BCRYPT_USE_SYSTEM_PREFERRED_RNG : constant ULONG
     := 16#0000_0002#;

   BCRYPT_SUCCESS    : constant NTSTATUS            := 0;

   function BCryptGenRandom
     (hAlgorithm : HANDLE := BCRYPT_ALG_HANDLE;
      pbBuffer   : System_Address;
      cbBuffer   : ULONG;
      dwFlags    : ULONG := BCRYPT_USE_SYSTEM_PREFERRED_RNG)
      return NTSTATUS
     with
       Import     => True,
       Convention => C,
       Link_Name  => "BCryptGenRandom",
       Global     => null,
       Pre        => pbBuffer /= System.Null_Address and then cbBuffer >= 1;

   procedure SecureZeroMemory
     (Address : PVOID;
      Size    : BUFFER_RNG_LENGTH)
     with
       Import     => True,
       Convention => C,
       Link_Name  => "RtlSecureZeroMemory",
       Global     => null,
       Pre        => Address /= System.Null_Address and then Size >= 1;

end BcryptGenRandom_Wrapper;
