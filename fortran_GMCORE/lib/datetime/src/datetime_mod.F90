module datetime_mod

  use timedelta_mod

  implicit none

  private

  public datetime_type
  public days_of_month
  public accum_days
  public days_of_year
  public is_leap_year
  public datetime_gregorian_calendar
  public datetime_noleap_calendar

  integer, parameter :: datetime_gregorian_calendar = 1
  integer, parameter :: datetime_noleap_calendar    = 2

  type datetime_type
    integer :: year = 1
    integer :: month = 1
    integer :: day = 1
    integer :: hour = 0
    integer :: minute = 0
    integer :: second = 0
    real(8) :: millisecond = 0
    real(8) :: timezone = 0.0d0
    integer :: calendar = datetime_gregorian_calendar
  contains
    procedure :: datetime_init_1
    procedure :: datetime_init_2
    generic   :: init => datetime_init_1, datetime_init_2
    procedure :: now
    procedure :: isoformat
    procedure :: timestamp
    procedure :: format
    procedure :: add
    procedure :: add_years
    procedure :: add_months
    procedure :: add_days
    procedure :: add_hours
    procedure :: add_minutes
    procedure :: add_seconds
    procedure :: add_milliseconds
    procedure :: days_in_year
    procedure, private :: assign
    procedure, private :: add_timedelta
    procedure, private :: sub_datetime
    procedure, private :: sub_timedelta
    procedure, private :: eq
    procedure, private :: neq
    procedure, private :: gt
    procedure, private :: ge
    procedure, private :: lt
    procedure, private :: le
    generic :: assignment(=) => assign
    generic :: operator(+) => add_timedelta
    generic :: operator(-) => sub_datetime
    generic :: operator(-) => sub_timedelta
    generic :: operator(==) => eq
    generic :: operator(/=) => neq
    generic :: operator(>) => gt
    generic :: operator(>=) => ge
    generic :: operator(<) => lt
    generic :: operator(<=) => le
  end type datetime_type

  type(datetime_type), parameter :: epoch = datetime_type(1970, 1, 1)

contains
  
  subroutine now(this)
  
    class(datetime_type), intent(inout) :: this
    
    integer values(8)
  
    call date_and_time(VALUES=values)
   
    this%year = values(1)
    this%month = values(2)
    this%day = values(3)
    this%hour = values(5)
    this%minute = values(6)
    this%second = values(7)
    this%millisecond = values(8)
  
  end subroutine now

  subroutine datetime_init_1(this, &
      year,  month,  day,  hour,  minute,  second, millisecond, &
             julday, days, hours, minutes, seconds, &
      timestamp, &
      timezone, calendar)

    class(datetime_type), intent(inout) :: this
    integer, intent(in), optional :: year
    integer, intent(in), optional :: month
    integer, intent(in), optional :: day
    integer, intent(in), optional :: hour
    integer, intent(in), optional :: minute
    integer, intent(in), optional :: second
    integer, intent(in), optional :: millisecond
    integer, intent(in), optional :: julday
    integer, intent(in), optional :: days
    integer, intent(in), optional :: hours
    integer, intent(in), optional :: minutes
    integer, intent(in), optional :: seconds
    class(*), intent(in), optional :: timestamp
    class(*), intent(in), optional :: timezone
    integer, intent(in), optional :: calendar

    real(8) residue_seconds
    integer mon

    if (present(calendar)) this%calendar = calendar

    if (present(timestamp)) then
      ! Assume the start date time is UTC 1970-01-01 00:00:00.
      this%year = 1970
      this%month = 1
      this%day = 1
      this%hour = 0
      this%minute = 0
      this%second = 0
      this%millisecond = 0
      select type (timestamp)
      type is (integer)
        residue_seconds = timestamp
      type is (real(4))
        residue_seconds = timestamp
      type is (real(8))
        residue_seconds = timestamp
      end select
      call this%add_days(int(residue_seconds / 86400.0))
      residue_seconds = mod(residue_seconds, 86400.0)
      call this%add_hours(int(residue_seconds / 3600.0))
      residue_seconds = mod(residue_seconds, 3600.0)
      call this%add_minutes(int(residue_seconds / 60.0))
      residue_seconds = mod(residue_seconds, 60.0)
      call this%add_seconds(int(residue_seconds))
      call this%add_milliseconds((residue_seconds - int(residue_seconds)) * 1000)
    else
      this%year = year
      if (present(julday)) then
        this%day = 0
        do mon = 1, 12
          this%day = this%day + days_of_month(year, mon, this%calendar)
          if (this%day > julday) exit
        end do
        this%month = min(mon, 12)
        this%day = julday - accum_days(year, this%month, 0, this%calendar)
      else
        if (present(month)) this%month = month
        if (present(day  )) this%day   = day
      end if
      if (present(hour       )) this%hour        = hour
      if (present(minute     )) this%minute      = minute
      if (present(second     )) this%second      = second
      if (present(millisecond)) this%millisecond = millisecond
      if (present(days       )) call this%add_days(days)
      if (present(hours      )) call this%add_hours(hours)
      if (present(minutes    )) call this%add_minutes(minutes)
      if (present(seconds    )) call this%add_seconds(seconds)
      if (this%second == 60) then
        call this%add_minutes(1)
        this%second = 0
      end if
      if (this%minute == 60) then
        call this%add_hours(1)
        this%minute = 0
      end if
      if (this%hour == 24) then
        call this%add_days(1)
        this%hour = 0
      end if
    end if
    if (present(timezone)) then
      select type (timezone)
      type is (integer)
        this%timezone = timezone
      type is (real(4))
        this%timezone = timezone
      type is (real(8))
        this%timezone = timezone
      end select
    end if

  end subroutine datetime_init_1

  subroutine datetime_init_2(this, datetime_str, format_str, timezone, calendar)

    class(datetime_type), intent(inout) :: this
    character(*), intent(in) :: datetime_str
    character(*), intent(in), optional :: format_str
    class(*), intent(in), optional :: timezone
    integer, intent(in), optional :: calendar

    integer i, j, ierr

    if (present(format_str)) then
      i = 1
      j = 1
      do while (i <= len_trim(format_str))
        if (format_str(i:i) == '%') then
          i = i + 1
          select case (format_str(i:i))
          case ('Y')
            read(datetime_str(j:j+3), '(I4)') this%year
            j = j + 4
          case ('m')
            read(datetime_str(j:j+1), '(I2)') this%month
            j = j + 2
          case ('d')
            read(datetime_str(j:j+1), '(I2)') this%day
            j = j + 2
          case ('H')
            read(datetime_str(j:j+1), '(I2)') this%hour
            j = j + 2
          case ('M')
            read(datetime_str(j:j+1), '(I2)') this%minute
            j = j + 2
          case ('S')
            read(datetime_str(j:j+1), '(I2)') this%second
            j = j + 2
          case ('Z')
            ! +08:00
            read(datetime_str(j:j+2), '(I3)') this%timezone
            j = j + 6
          case default
            j = j + 1
          end select
        else
          j = j + 1
        end if
        i = i + 1
      end do
    else
      ! TODO: I assume UTC time for the time being.
      read(datetime_str(1:4), '(I4)', iostat=ierr) this%year
      if (ierr /= 0) then
        write(*, *) '[Error]: datetime: Invalid argument ' // trim(datetime_str) // '!'
        stop 1
      end if
      read(datetime_str(6:7), '(I2)', iostat=ierr) this%month
      if (ierr /= 0) then
        write(*, *) '[Error]: datetime: Invalid argument ' // trim(datetime_str) // '!'
        stop 1
      end if
      read(datetime_str(9:10), '(I2)', iostat=ierr) this%day
      if (ierr /= 0) then
        write(*, *) '[Error]: datetime: Invalid argument ' // trim(datetime_str) // '!'
        stop 1
      end if
      read(datetime_str(12:13), '(I2)', iostat=ierr) this%hour
      if (ierr /= 0) then
        write(*, *) '[Error]: datetime: Invalid argument ' // trim(datetime_str) // '!'
        stop 1
      end if
      read(datetime_str(15:16), '(I2)', iostat=ierr) this%minute
      if (ierr /= 0) then
        write(*, *) '[Error]: datetime: Invalid argument ' // trim(datetime_str) // '!'
        stop 1
      end if
      read(datetime_str(18:19), '(I2)', iostat=ierr) this%second
      if (ierr /= 0) then
        write(*, *) '[Error]: datetime: Invalid argument ' // trim(datetime_str) // '!'
        stop 1
      end if
    end if

    if (present(timezone)) then
      select type (timezone)
      type is (integer)
        this%timezone = timezone
      type is (real(4))
        this%timezone = timezone
      type is (real(8))
        this%timezone = timezone
      class default
        write(*, *) '[Error]: datetime: Invalid timezone argument type! Only integer and real are supported.'
        stop 1
      end select
    end if

    if (present(calendar)) this%calendar = calendar

  end subroutine datetime_init_2

  function isoformat(this) result(res)

    class(datetime_type), intent(in) :: this
    character(:), allocatable :: res

    character(30) tmp

    if (this%timezone == 0) then
      write(tmp, "(I4.4, '-', I2.2, '-', I2.2, 'T', I2.2, ':', I2.2, ':', I2.2, 'Z')") &
        this%year, this%month, this%day, this%hour, this%minute, this%second
    else
      write(tmp, "(I4.4, '-', I2.2, '-', I2.2, 'T', I2.2, ':', I2.2, ':', I2.2, SP, I3.2, ':00')") &
        this%year, this%month, this%day, this%hour, this%minute, this%second, int(this%timezone)
    end if

    res = trim(tmp)

  end function isoformat

  function timestamp(this, timezone)

    class(datetime_type), intent(in) :: this
    class(*), intent(in), optional :: timezone
    real(8) timestamp

    type(timedelta_type) dt

    dt = this - epoch
    timestamp = dt%total_seconds()
    if (present(timezone)) then
      select type (timezone)
      type is (integer)
        timestamp = timestamp - (this%timezone - timezone) * 3600
      type is (real(4))
        timestamp = timestamp - (this%timezone - timezone) * 3600
      type is (real(8))
        timestamp = timestamp - (this%timezone - timezone) * 3600
      end select
    end if

  end function timestamp

  function format(this, format_str) result(res)

    class(datetime_type), intent(in) :: this
    character(*), intent(in) :: format_str
    character(:), allocatable :: res

    character(100) tmp
    integer i, j

    tmp = ''
    i = 1
    j = 1
    do while (i <= len_trim(format_str))
      if (format_str(i:i) == '%') then
        i = i + 1
        select case (format_str(i:i))
        case ('Y')
          write(tmp(j:j+3), '(I4.4)') this%year
          j = j + 4
        case ('y')
          write(tmp(j:j+1), '(I2.2)') mod(this%year, 100)
          j = j + 2
        case ('j')
          write(tmp(j:j+2), '(I3.3)') this%days_in_year()
          j = j + 3
        case ('m')
          write(tmp(j:j+1), '(I2.2)') this%month
          j = j + 2
        case ('d')
          write(tmp(j:j+1), '(I2.2)') this%day
          j = j + 2
        case ('H')
          write(tmp(j:j+1), '(I2.2)') this%hour
          j = j + 2
        case ('M')
          write(tmp(j:j+1), '(I2.2)') this%minute
          j = j + 2
        case ('S')
          write(tmp(j:j+1), '(I2.2)') this%second
          j = j + 2
        case ('s')
          write(tmp(j:j+4), '(I5.5)') this%hour * 3600 + this%minute * 60 + this%second
        end select
      else
        write(tmp(j:j), '(A1)') format_str(i:i)
        j = j + 1
      end if
      i = i + 1
    end do
    res = trim(tmp)

  end function format

  pure subroutine add(this, years, months, days, hours, minutes, seconds)

    class(datetime_type), intent(inout) :: this
    class(*), intent(in), optional :: years
    class(*), intent(in), optional :: months
    class(*), intent(in), optional :: days
    class(*), intent(in), optional :: hours
    class(*), intent(in), optional :: minutes
    class(*), intent(in), optional :: seconds

    if (present(years  )) call this%add_years  (years  )
    if (present(months )) call this%add_months (months )
    if (present(days   )) call this%add_days   (days   )
    if (present(hours  )) call this%add_hours  (hours  )
    if (present(minutes)) call this%add_minutes(minutes)
    if (present(seconds)) call this%add_seconds(seconds)

  end subroutine add

  pure subroutine add_years(this, years)

    class(datetime_type), intent(inout) :: this
    class(*), intent(in) :: years

    select type (years)
    type is (integer)
      this%year = this%year + years
    type is (real(4))
      this%year = this%year + years
    type is (real(8))
      this%year = this%year + years
    end select

  end subroutine add_years

  pure subroutine add_months(this, months)

    class(datetime_type), intent(inout) :: this
    class(*), intent(in) :: months

    select type (months)
    type is (integer)
      this%month = this%month + months
    type is (real(4))
      this%month = this%month + months
    type is (real(8))
      this%month = this%month + months
    end select

    if (this%month > 12) then
      this%year = this%year + this%month / 12
      this%month = mod(this%month, 12)
    else if (this%month < 1) then
      this%year = this%year + this%month / 12 - 1
      this%month = 12 + mod(this%month, 12)
    end if

  end subroutine add_months

  pure subroutine add_days(this, days)

    class(datetime_type), intent(inout) :: this
    class(*), intent(in) :: days

    real(8) residue_days
    integer month_days

    select type (days)
    type is (integer)
      residue_days = 0
      this%day = this%day + days
    type is (real(4))
      residue_days = days - int(days)
      this%day = this%day + days
    type is (real(8))
      residue_days = days - int(days)
      this%day = this%day + days
    end select

    if (residue_days /= 0) then
      call this%add_hours(residue_days * 24)
    end if

    do
      if (this%day < 1) then
        call this%add_months(-1)
        month_days = days_of_month(this%year, this%month, this%calendar)
        this%day = this%day + month_days
      else
        month_days = days_of_month(this%year, this%month, this%calendar)
        if (this%day > month_days) then
          call this%add_months(1)
          this%day = this%day - month_days
        else
          exit
        end if
      end if
    end do

  end subroutine add_days

  pure subroutine add_hours(this, hours)

    class(datetime_type), intent(inout) :: this
    class(*), intent(in) :: hours

    real(8) residue_hours

    select type (hours)
    type is (integer)
      residue_hours = 0
      this%hour = this%hour + hours
    type is (real(4))
      residue_hours = hours - int(hours)
      this%hour = this%hour + hours
    type is (real(8))
      residue_hours = hours - int(hours)
      this%hour = this%hour + hours
    end select

    if (residue_hours /= 0) then
      call this%add_minutes(residue_hours * 60)
    end if

    if (this%hour >= 24) then
      call this%add_days(this%hour / 24)
      this%hour = mod(this%hour, 24)
    else if (this%hour < 0) then
      if (mod(this%hour, 24) == 0) then
        call this%add_days(this%hour / 24)
        this%hour = 0
      else
        call this%add_days(this%hour / 24 - 1)
        this%hour = mod(this%hour, 24) + 24
      end if
    end if

  end subroutine add_hours

  pure subroutine add_minutes(this, minutes)

    class(datetime_type), intent(inout) :: this
    class(*), intent(in) :: minutes

    real(8) residue_minutes

    select type (minutes)
    type is (integer)
      residue_minutes = 0
      this%minute = this%minute + minutes
    type is (real(4))
      residue_minutes = minutes - int(minutes)
      this%minute = this%minute + minutes
    type is (real(8))
      residue_minutes = minutes - int(minutes)
      this%minute = this%minute + minutes
    end select

    if (residue_minutes /= 0) then
      call this%add_seconds(residue_minutes * 60)
    end if

    if (this%minute >= 60) then
      call this%add_hours(this%minute / 60)
      this%minute = mod(this%minute, 60)
    else if (this%minute < 0) then
      if (mod(this%minute, 60) == 0) then
        call this%add_hours(this%minute / 60)
        this%minute = 0
      else
        call this%add_hours(this%minute / 60 - 1)
        this%minute = mod(this%minute, 60) + 60
      end if
    end if

  end subroutine add_minutes

  pure subroutine add_seconds(this, seconds)

    class(datetime_type), intent(inout) :: this
    class(*), intent(in) :: seconds

    real(8) residue_seconds

    select type (seconds)
    type is (integer)
      residue_seconds = 0
      this%second = this%second + seconds
    type is (real(4))
      residue_seconds = seconds - int(seconds)
      this%second = this%second + seconds
    type is (real(8))
      residue_seconds = seconds - int(seconds)
      this%second = this%second + seconds
    end select

    if (residue_seconds /= 0) then
      call this%add_milliseconds(residue_seconds * 1000)
    end if

    if (this%second >= 60) then
      call this%add_minutes(this%second / 60)
      this%second = mod(this%second, 60)
    else if (this%second < 0) then
      if (mod(this%second, 60) == 0) then
        call this%add_minutes(this%second / 60)
        this%second = 0
      else
        call this%add_minutes(this%second / 60 - 1)
        this%second = mod(this%second, 60) + 60
      end if
    end if

  end subroutine add_seconds

  pure subroutine add_milliseconds(this, milliseconds)

    class(datetime_type), intent(inout) :: this
    class(*), intent(in) :: milliseconds

    select type (milliseconds)
    type is (integer)
      this%millisecond = this%millisecond + milliseconds
    type is (real(4))
      this%millisecond = this%millisecond + milliseconds
    type is (real(8))
      this%millisecond = this%millisecond + milliseconds
    end select

    if (this%millisecond >= 1000) then
      call this%add_seconds(int(this%millisecond / 1000))
      this%millisecond = mod(this%millisecond, 1000.0)
    else if (this%millisecond < 0) then
      if (mod(this%millisecond, 1000.0) == 0) then
        call this%add_seconds(int(this%millisecond / 1000))
        this%millisecond = 0
      else
        call this%add_seconds(int(this%millisecond / 1000) - 1)
        this%millisecond = mod(this%millisecond, 1000.0d0) + 1000
      end if
    end if

  end subroutine add_milliseconds

  pure integer function days_in_year(this) result(res)

    class(datetime_type), intent(in) :: this

    integer month

    res = 0
    do month = 1, this%month - 1
      res = res + days_of_month(this%year, month, this%calendar)
    end do
    res = res + this%day

  end function days_in_year

  pure elemental subroutine assign(this, other)

    class(datetime_type), intent(inout) :: this
    class(datetime_type), intent(in) :: other

    this%calendar    = other%calendar
    this%year        = other%year
    this%month       = other%month
    this%day         = other%day
    this%hour        = other%hour
    this%minute      = other%minute
    this%second      = other%second
    this%millisecond = other%millisecond
    this%timezone    = other%timezone

  end subroutine assign

  elemental type(datetime_type) function add_timedelta(this, td) result(res)

    class(datetime_type), intent(in) :: this
    type(timedelta_type), intent(in) :: td

    res = this
    call res%add_milliseconds(td%milliseconds)
    call res%add_seconds(td%seconds)
    call res%add_minutes(td%minutes)
    call res%add_hours(td%hours)
    call res%add_days(td%days)
    call res%add_months(td%months)

  end function add_timedelta

  pure elemental type(datetime_type) function sub_timedelta(this, td) result(res)

    class(datetime_type), intent(in) :: this
    type(timedelta_type), intent(in) :: td

    res = this
    call res%add_milliseconds(-td%milliseconds)
    call res%add_seconds(-td%seconds)
    call res%add_minutes(-td%minutes)
    call res%add_hours(-td%hours)
    call res%add_days(-td%days)
    call res%add_months(-td%months)

  end function sub_timedelta

  type(timedelta_type) recursive function sub_datetime(this, other) result(res)

    class(datetime_type), intent(in) :: this
    class(datetime_type), intent(in) :: other

    integer year, month, days, hours, minutes, seconds
    real(8) milliseconds

    days = 0
    hours = 0
    minutes = 0
    seconds = 0
    milliseconds = 0

    if (this >= other) then
      if (this%year == other%year) then
        if (this%month == other%month) then
          if (this%day == other%day) then
            if (this%hour == other%hour) then
              if (this%minute == other%minute) then
                if (this%second == other%second) then
                  milliseconds = milliseconds + this%millisecond - other%millisecond
                else
                  seconds = seconds + this%second - other%second - 1
                  milliseconds = milliseconds + 1000 - other%millisecond
                  milliseconds = milliseconds + this%millisecond
                end if
              else
                minutes = minutes + this%minute - other%minute - 1
                seconds = seconds + 60 - other%second - 1
                seconds = seconds + this%second
                milliseconds = milliseconds + 1000 - other%millisecond
                milliseconds = milliseconds + this%millisecond
              end if
            else
              hours = hours + this%hour - other%hour - 1
              minutes = minutes + 60 - other%minute - 1
              minutes = minutes + this%minute
              seconds = seconds + 60 - other%second - 1
              seconds = seconds + this%second
              milliseconds = milliseconds + 1000 - other%millisecond
              milliseconds = milliseconds + this%millisecond
            end if
          else
            days = days + this%day - other%day - 1
            hours = hours + 24 - other%hour - 1
            hours = hours + this%hour
            minutes = minutes + 60 - other%minute - 1
            minutes = minutes + this%minute
            seconds = seconds + 60 - other%second - 1
            seconds = seconds + this%second
            milliseconds = milliseconds + 1000 - other%millisecond
            milliseconds = milliseconds + this%millisecond
          end if
        else
          do month = other%month + 1, this%month - 1
            days = days + days_of_month(this%year, month, this%calendar)
          end do
          days = days + days_of_month(other%year, other%month, other%calendar) - other%day - 1
          days = days + this%day
          hours = hours + 24 - other%hour - 1
          hours = hours + this%hour
          minutes = minutes + 60 - other%minute - 1
          minutes = minutes + this%minute
          seconds = seconds + 60 - other%second - 1
          seconds = seconds + this%second
          milliseconds = milliseconds + 1000 - other%millisecond
          milliseconds = milliseconds + this%millisecond
        end if
      else
        do year = other%year + 1, this%year - 1
          if (this%calendar == datetime_gregorian_calendar) then
            days = days + 365 + merge(1, 0, is_leap_year(year))
          else
            days = days + 365
          end if
        end do
        do month = other%month + 1, 12
          days = days + days_of_month(other%year, month, other%calendar)
        end do
        do month = 1, this%month - 1
          days = days + days_of_month(this%year, month, this%calendar)
        end do
        days = days + days_of_month(other%year, other%month, other%calendar) - other%day - 1
        days = days + this%day
        hours = hours + 24 - other%hour - 1
        hours = hours + this%hour
        minutes = minutes + 60 - other%minute - 1
        minutes = minutes + this%minute
        seconds = seconds + 60 - other%second - 1
        seconds = seconds + this%second
        milliseconds = milliseconds + 1000 - other%millisecond
        milliseconds = milliseconds + this%millisecond
      end if
      ! Carry over.
      if (milliseconds >= 1000) then
        milliseconds = milliseconds - 1000
        seconds = seconds + 1
      end if
      if (seconds >= 60) then
        seconds = seconds - 60
        minutes = minutes + 1
      end if
      if (minutes >= 60) then
        minutes = minutes - 60
        hours = hours + 1
      end if
      if (hours >= 24) then
        hours = hours - 24
        days = days + 1
      end if
      call res%init( &
        days=dble(days), &
        hours=dble(hours), &
        minutes=dble(minutes), &
        seconds=dble(seconds), &
        milliseconds=dble(milliseconds))
    else
      res = sub_datetime(other, this)
      res = res%negate()
    end if

  end function sub_datetime

  pure elemental logical function eq(this, other)

    class(datetime_type), intent(in) :: this
    class(datetime_type), intent(in) :: other

    eq = this%year        == other%year   .and. &
         this%month       == other%month  .and. &
         this%day         == other%day    .and. &
         this%hour        == other%hour   .and. &
         this%minute      == other%minute .and. &
         this%second      == other%second .and. &
         this%millisecond == other%millisecond

  end function eq

  pure elemental logical function neq(this, other)

    class(datetime_type), intent(in) :: this
    class(datetime_type), intent(in) :: other

    neq = .not. this == other

  end function neq

  pure elemental logical function gt(this, other)

    class(datetime_type), intent(in) :: this
    class(datetime_type), intent(in) :: other

    if (this%year < other%year) then
      gt = .false.
      return
    else if (this%year > other%year) then
      gt = .true.
      return
    end if

    if (this%month < other%month) then
      gt = .false.
      return
    else if (this%month > other%month) then
      gt = .true.
      return
    end if

    if (this%day < other%day) then
      gt = .false.
      return
    else if (this%day > other%day) then
      gt = .true.
      return
    end if

    if (this%hour < other%hour) then
      gt = .false.
      return
    else if (this%hour > other%hour) then
      gt = .true.
      return
    end if

    if (this%minute < other%minute) then
      gt = .false.
      return
    else if (this%minute > other%minute) then
      gt = .true.
      return
    end if

    if (this%second < other%second) then
      gt = .false.
      return
    else if (this%second > other%second) then
      gt = .true.
      return
    end if

    if (this%millisecond < other%millisecond) then
      gt = .false.
      return
    else if (this%millisecond < other%millisecond) then
      gt = .true.
      return
    end if

    gt = this /= other

  end function gt

  pure elemental logical function ge(this, other)

    class(datetime_type), intent(in) :: this
    class(datetime_type), intent(in) :: other

    ge = this > other .or. this == other

  end function ge

  pure elemental logical function lt(this, other)

    class(datetime_type), intent(in) :: this
    class(datetime_type), intent(in) :: other

    lt = other > this

  end function lt

  pure elemental logical function le(this, other)

    class(datetime_type), intent(in) :: this
    class(datetime_type), intent(in) :: other

    le = other > this .or. this == other

  end function le

  pure integer function days_of_month(year, month, calendar) result(res)

    integer, intent(in) :: year
    integer, intent(in) :: month
    integer, intent(in) :: calendar

    integer, parameter :: days(12) = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    if (month == 2 .and. is_leap_year(year) .and. calendar == datetime_gregorian_calendar) then
      res = 29
    else
      res = days(month)
    end if

  end function days_of_month

  pure integer function accum_days(year, month, day, calendar) result(res)

    integer, intent(in) :: year
    integer, intent(in) :: month
    integer, intent(in) :: day
    integer, intent(in) :: calendar

    integer mon

    res = day
    do mon = 1, month - 1
      res = res + days_of_month(year, mon, calendar)
    end do

  end function accum_days

  pure integer function days_of_year(year, calendar) result(res)

    integer, intent(in) :: year
    integer, intent(in) :: calendar

    select case (calendar)
    case (datetime_gregorian_calendar)
      if (is_leap_year(year)) then
        res = 366
      else
        res = 365
      end if
    case (datetime_noleap_calendar)
      res = 365
    end select

  end function days_of_year

  pure logical function is_leap_year(year) result(res)

    integer, intent(in) :: year

    res = (mod(year, 4) == 0 .and. .not. mod(year, 100) == 0) .or. (mod(year, 400) == 0)

  end function is_leap_year

end module datetime_mod
