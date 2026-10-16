-- Ada.Synchronous_Task_Control — RavenSPARK coordination primitive
-- Provides Suspension_Object operations for starting and stopping tasks
-- in response to events. SPARK derives annotations intentionally omit
-- the Ada runtime's internal reads of SO (see package comments).

package Ada.Synchronous_Task_Control
is

  type Suspension_Object is limited private;

  procedure Set_True (S : in out Suspension_Object);
  --# derives S from ;
  -- Note the apparent mismatch between the parameter mode and the
  -- derives annotation. This arises because the Ada run-time system
  -- needs to read SO in order to determine whether any tasks should
  -- now be started whereas, for flow analysis purposes, we only need
  -- to record the fact that SO is given a new value that does not
  -- depend on any import.

  procedure Set_False (S : in out Suspension_Object);
  --# derives S from ;
  -- See comment on operation Set_True

  procedure Suspend_Until_True (S : in out Suspension_Object);
  --# derives S from ;
  -- See comment on operation Set_True

private
  --# hide Ada.Synchronous_Task_Control;
  -- we do not need to know the implementation details of this package
  -- for our analysis purposes
end Ada.Synchronous_Task_Control;
