module const_mod

  use, intrinsic :: ieee_arithmetic
  use flogger

#ifdef REAL_KIND
  integer, parameter :: r8 = REAL_KIND
#else
  integer, parameter :: r8 = 8
#endif

  real( 8), parameter :: pi     = atan(1.0d0) * 4.0d0
  real( 8), parameter :: pi2    = pi * 2
  real( 8), parameter :: pi05   = pi * 0.5d0
  real( 8), parameter :: deg    = 180.0d0 / pi
  real( 8), parameter :: rad    = pi / 180.0d0
  real(r8), parameter :: eps    = epsilon(1.0_r8)
  real(r8), parameter :: inf    = huge(1.0_r8)
  real(r8), parameter :: karman = 0.4_r8             ! Karman constant

  real(r8)            :: omega      ! s-1
  real(r8)            :: radius     ! m
  real(r8)            :: g          ! m2 s-2
  real(r8)            :: Rd         ! J kg-1 K-1
  real(r8)            :: Rv         ! J kg-1 K-1
  real(r8)            :: cpd        ! J kg-1 K-1
  real(r8)            :: cvd        ! J kg-1 K-1
  real(r8)            :: Lv         !
  real(r8)            :: Rd_o_Rv
  real(r8)            :: Rv_o_Rd
  real(r8)            :: Rd_o_cpd
  real(r8)            :: Rd_o_g
  real(r8)            :: cpd_o_cvd
  real(r8)            :: cvd_o_cpd
  real(r8)            :: lapse_rate ! K m-1
  real(r8)            :: p0         ! Pa

  integer, parameter :: nest_ratio = 3
  integer, parameter :: inf_i4 = 10000000

  integer, parameter :: all_pass      = 0
  integer, parameter :: forward_pass  = 1
  integer, parameter :: backward_pass = 2
  integer, parameter :: nh_pass_1     = 3
  integer, parameter :: nh_pass_2     = 4

  integer, parameter :: west  = 1
  integer, parameter :: east  = 2
  integer, parameter :: south = 3
  integer, parameter :: north = 4

contains

  subroutine const_init(planet)

    character(*), intent(in) :: planet

    select case (planet)
    case ('earth')
      omega      = 2 * pi / 86400.0d0
      radius     = 6.37122d6
      g          = 9.80616d0
      Rd         = 287.04d0
      Rv         = 461.497d0
      cpd        = 1004.0d0
      cvd        = 717.0d0
      lapse_rate = 0.006d0
      Rd_o_Rv    = Rd / Rv
      Rv_o_Rd    = Rv / Rd
      p0         = 1.0d5
    case ('mars')
      omega      = 2 * pi / 88642.663d0
      radius     = 3.38992d6
      g          = 3.72d0
      Rd         = 191.84d0
      cpd        = 735.0d0
      cvd        = 543.16d0
      lapse_rate = 5.06d-3
      p0         = 6.1d2 ! FIXME: Should we use 6 hPa?
    case default
      call log_error('Invalid planet!')
    end select

    Rd_o_g  = Rd / g
    Rd_o_cpd = Rd / cpd
    cpd_o_cvd = cpd / cvd
    cvd_o_cpd = cvd / cpd

  end subroutine const_init

end module const_mod
