module timedelta_mod

  implicit none

  private

  public timedelta_type
  public timedelta

  type timedelta_type
    integer :: months = 0.0d0
    real(8) :: days = 0.0d0
    real(8) :: hours = 0.0d0
    real(8) :: minutes = 0.0d0
    real(8) :: seconds = 0.0d0
    real(8) :: milliseconds = 0.0d0
  contains
    procedure :: init
    procedure :: total_seconds
    procedure :: total_minutes
    procedure :: total_hours
    procedure :: total_days
    procedure :: negate
    procedure :: eq
    procedure :: neq
    procedure :: gt
    procedure :: ge
    procedure :: lt
    procedure :: le
    generic :: operator(==) => eq
    generic :: operator(/=) => neq
    generic :: operator(>) => gt
    generic :: operator(>=) => ge
    generic :: operator(<) => lt
    generic :: operator(<=) => le
  end type timedelta_type

contains

  type(timedelta_type) function timedelta(months, days, hours, minutes, seconds, milliseconds) result(res)

    class(*), intent(in), optional :: months
    class(*), intent(in), optional :: days
    class(*), intent(in), optional :: hours
    class(*), intent(in), optional :: minutes
    class(*), intent(in), optional :: seconds
    class(*), intent(in), optional :: milliseconds

    call res%init(months, days, hours, minutes, seconds, milliseconds)

  end function timedelta

  subroutine init(this, months, days, hours, minutes, seconds, milliseconds)

    class(timedelta_type), intent(inout) :: this
    class(*), intent(in), optional :: months
    class(*), intent(in), optional :: days
    class(*), intent(in), optional :: hours
    class(*), intent(in), optional :: minutes
    class(*), intent(in), optional :: seconds
    class(*), intent(in), optional :: milliseconds

    if (present(months)) then
      select type (months)
      type is (integer)
        this%months = months
      type is (real(4))
        this%months = months
      type is (real(8))
        this%months = months
      class default
        stop 'Unsupported argument type!'
      end select
    end if

    if (present(days)) then
      select type (days)
      type is (integer)
        this%days = days
      type is (real(4))
        this%days = days
      type is (real(8))
        this%days = days
      class default
        stop 'Unsupported argument type!'
      end select
    end if

    if (present(hours)) then
      select type (hours)
      type is (integer)
        this%hours = hours
      type is (real(4))
        this%hours = hours
      type is (real(8))
        this%hours = hours
      class default
        stop 'Unsupported argument type!'
      end select
    end if

    if (present(minutes)) then
      select type (minutes)
      type is (integer)
        this%minutes = minutes
      type is (real(4))
        this%minutes = minutes
      type is (real(8))
        this%minutes = minutes
      class default
        stop 'Unsupported argument type!'
      end select
    end if

    if (present(seconds)) then
      select type (seconds)
      type is (integer)
        this%seconds = seconds
      type is (real(4))
        this%seconds = seconds
      type is (real(8))
        this%seconds = seconds
      class default
        stop 'Unsupported argument type!'
      end select
    end if

    if (present(milliseconds)) then
      select type (milliseconds)
      type is (integer)
        this%milliseconds = milliseconds
      type is (real(4))
        this%milliseconds = milliseconds
      type is (real(8))
        this%milliseconds = milliseconds
      class default
        stop 'Unsupported argument type!'
      end select
    end if

  end subroutine init

  pure real(8) function total_seconds(this)

    class(timedelta_type), intent(in) :: this

    if (this%months == 0.0d0) then
      total_seconds = this%days * 86400 + this%hours * 3600 + this%minutes * 60 + this%seconds + this%milliseconds * 1.0d-3
    else
      total_seconds = -1
    end if

  end function total_seconds

  pure real(8) function total_minutes(this)

    class(timedelta_type), intent(in) :: this

    if (this%months == 0.0d0) then
      total_minutes = this%days * 1440 + this%hours * 60 + this%minutes + (this%seconds + this%milliseconds * 1.0d-3) / 60.0d0
    else
      total_minutes = -1
    end if

  end function total_minutes

  pure real(8) function total_hours(this)

    class(timedelta_type), intent(in) :: this

    if (this%months == 0.0d0) then
      total_hours = this%days * 24 + this%hours + (this%minutes + (this%seconds + this%milliseconds * 1.0d-3) / 60.0d0) / 60.0d0
    else
      total_hours = -1
    end if

  end function total_hours

  pure real(8) function total_days(this)

    class(timedelta_type), intent(in) :: this

    if (this%months == 0.0d0) then
      total_days = this%days + (this%hours + (this%minutes + (this%seconds + this%milliseconds * 1.0d-3) / 60.0d0) / 60.0d0) / 24.0d0
    else
      total_days = -1
    end if

  end function total_days

  pure elemental type(timedelta_type) function negate(this) result(res)

    class(timedelta_type), intent(in) :: this

    res%days = - this%days
    res%hours = - this%hours
    res%minutes = - this%minutes
    res%seconds = - this%seconds
    res%milliseconds = - this%milliseconds

  end function negate

  pure elemental logical function eq(this, other)

    class(timedelta_type), intent(in) :: this
    class(timedelta_type), intent(in) :: other

    eq = this%total_seconds() == other%total_seconds()

  end function eq

  pure elemental logical function neq(this, other)

    class(timedelta_type), intent(in) :: this
    class(timedelta_type), intent(in) :: other

    neq = this%total_seconds() /= other%total_seconds()

  end function neq

  pure elemental logical function gt(this, other)

    class(timedelta_type), intent(in) :: this
    class(timedelta_type), intent(in) :: other

    gt = this%total_seconds() > other%total_seconds()

  end function gt

  pure elemental logical function ge(this, other)

    class(timedelta_type), intent(in) :: this
    class(timedelta_type), intent(in) :: other

    ge = this%total_seconds() >= other%total_seconds()

  end function ge

  pure elemental logical function lt(this, other)

    class(timedelta_type), intent(in) :: this
    class(timedelta_type), intent(in) :: other

    lt = this%total_seconds() < other%total_seconds()

  end function lt

  pure elemental logical function le(this, other)

    class(timedelta_type), intent(in) :: this
    class(timedelta_type), intent(in) :: other

    le = this%total_seconds() <= other%total_seconds()

  end function le

end module timedelta_mod
