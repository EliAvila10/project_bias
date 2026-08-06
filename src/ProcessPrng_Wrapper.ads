with System;
with Interfaces;
with Interfaces.C;
with Ada.Real_Time;

with Windows_Data_Types;

package ProcessPrng_Wrapper with SPARK_Mode => On is

   use System;
   use Interfaces.C;
   use Interfaces;
   use Ada.Real_Time;

   use Windows_Data_Types;

   procedure ProcessPrng_Public
     (Buffer : in out BUFFER_RNG;
      Status : in out NTSTATUS)
     with
       Global  => (Input => Ada.Real_Time.Clock_Time),
       Depends => (Buffer => Buffer,
                   Status => (Buffer, Status),
                   null   => Ada.Real_Time.Clock_Time),
       Pre     => Buffer'First = 0
       and then Buffer'Length >= 32
       and then Status /= 1,
       Post    => (if Status = 1 then
                     Buffer /= (Buffer'Range => 0)
                       else
                         Buffer = (Buffer'Range => 0));

private

   Interval : constant Ada.Real_Time.Time_Span := Milliseconds (MS => 2_000);
   Retry    : Ada.Real_Time.Time           := Ada.Real_Time.Clock;

   ProcessPrng_Success : constant NTSTATUS := 1;

   function ProcessPrng
     (pbData : System_Address;
      cbData : BUFFER_RNG_LENGTH)
      return NTSTATUS
     with
       Import     => True,
       Convention => C,
       Link_Name  => "ProcessPrng",
       Global     => null,
       Pre => pbData /= System.Null_Address and then cbData >= 1;

   pragma Weak_External (ProcessPrng);

   procedure SecureZeroMemory
     (Address : PVOID;
      Size    : BUFFER_RNG_LENGTH)
     with
       Import     => True,
       Convention => C,
       Link_Name  => "RtlSecureZeroMemory",
       Global     => null,
       Pre        => Address /= System.Null_Address and then Size >= 1;

end ProcessPrng_Wrapper;
