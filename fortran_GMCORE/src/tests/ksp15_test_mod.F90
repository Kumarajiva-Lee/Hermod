module ksp15_test_mod

  use namelist_mod
  use const_mod
  use parallel_mod
  use block_mod
  use vert_coord_mod
  use formula_mod

  implicit none

  private

  public ksp15_test_set_params
  public ksp15_01_test_set_ic
  public ksp15_02_test_set_ic

  real(r8), parameter :: teq  = 300.0_r8     ! K
  real(r8), parameter :: peq  = 1.0e5_r8     ! Pa
  real(r8), parameter :: ueq  = 20.0_r8      ! m s-1
  real(r8), parameter :: X    = 166.7_r8
  real(r8)            :: h0
  real(r8), parameter :: d0   = 5000.0_r8    ! m
  real(r8), parameter :: xi0  = 4000.0_r8    ! m
  real(r8), parameter :: lonc = pi
  real(r8), parameter :: latc = 0.0_r8

contains

  subroutine ksp15_test_set_params()

    omega = 0.0_r8
    radius = radius / X

  end subroutine ksp15_test_set_params

  subroutine ksp15_01_test_set_ic(block)

    type(block_type), intent(inout), target :: block

    real(r8) dlon, r0
    integer i, j, k

    h0 = 25.0_r8

    associate (mesh   => block%mesh            , &
               u      => block%dstate(1)%u_lon , &
               v      => block%dstate(1)%v_lat , &
               t      => block%dstate(1)%t     , &
               pt     => block%dstate(1)%pt    , &
               gzs    => block%static   %gzs   , &
               phs    => block%dstate(1)%phs   , &
               ph     => block%dstate(1)%ph    , &
               ph_lev => block%dstate(1)%ph_lev, &
               gz_lev => block%dstate(1)%gz_lev)
      do k = mesh%full_kds, mesh%full_kde
        do j = mesh%full_jds, mesh%full_jde
          do i = mesh%half_ids, mesh%half_ide
            u(i,j,k) = ueq * mesh%full_cos_lat(j)
          end do
        end do
      end do
      call fill_halo(block%halo, u, full_lon=.false., full_lat=.true., full_lev=.true.)

      do j = mesh%full_jds, mesh%full_jde
        do i = mesh%full_ids, mesh%full_ide
          dlon = abs(mesh%full_lon(i) - lonc)
          dlon = min(pi2 - dlon, dlon)
          r0 = radius * dlon
          gzs(i,j) = g * h0 * exp(-r0**2 / d0**2) * cos(pi * r0 / xi0)**2 * mesh%full_cos_lat(j)
        end do
      end do
      call fill_halo(block%halo, gzs, full_lon=.true., full_lat=.true.)

      do j = mesh%full_jds, mesh%full_jde
        do i = mesh%full_ids, mesh%full_ide
          phs(i,j) = peq * exp(-0.5_r8 * ueq**2 / Rd / teq * mesh%full_sin_lat(j)**2 - gzs(i,j) / Rd / teq)
        end do
      end do
      call fill_halo(block%halo, phs, full_lon=.true., full_lat=.true.)

      do k = mesh%half_kds, mesh%half_kde
        do j = mesh%full_jds, mesh%full_jde
          do i = mesh%full_ids, mesh%full_ide
            ph_lev(i,j,k) = vert_coord_calc_ph_lev(k, phs(i,j))
          end do
        end do
      end do
      call fill_halo(block%halo, ph_lev, full_lon=.true., full_lat=.true., full_lev=.false.)

      do k = mesh%full_kds, mesh%full_kde
        do j = mesh%full_jds, mesh%full_jde
          do i = mesh%full_ids, mesh%full_ide
            ph(i,j,k) = 0.5d0 * (ph_lev(i,j,k) + ph_lev(i,j,k+1))
          end do
        end do
      end do
      call fill_halo(block%halo, ph, full_lon=.true., full_lat=.true., full_lev=.true.)

      do k = mesh%full_kds, mesh%full_kde
        do j = mesh%full_jds, mesh%full_jde
          do i = mesh%full_ids, mesh%full_ide
            t(i,j,k) = teq
            pt(i,j,k) = potential_temperature(t(i,j,k), ph(i,j,k), 0.0_r8)
          end do
        end do
      end do
      call fill_halo(block%halo, t , full_lon=.true., full_lat=.true., full_lev=.true.)
      call fill_halo(block%halo, pt, full_lon=.true., full_lat=.true., full_lev=.true.)

      do k = mesh%half_kds, mesh%half_kde
        do j = mesh%full_jds, mesh%full_jde
          do i = mesh%full_ids, mesh%full_ide
            gz_lev(i,j,k) = Rd * teq * log(peq / ph_lev(i,j,k)) - 0.5_r8 * ueq**2 * mesh%full_sin_lat(j)**2
          end do
        end do
      end do
      call fill_halo(block%halo, gz_lev, full_lon=.true., full_lat=.true., full_lev=.false.)
    end associate

  end subroutine ksp15_01_test_set_ic

  subroutine ksp15_02_test_set_ic(block)

    type(block_type), intent(inout), target :: block

    real(r8) r
    integer i, j, k

    h0 = 250.0_r8

    associate (mesh   => block%mesh            , &
               u      => block%dstate(1)%u_lon , &
               v      => block%dstate(1)%v_lat , &
               t      => block%dstate(1)%t     , &
               pt     => block%dstate(1)%pt    , &
               gzs    => block%static   %gzs   , &
               phs    => block%dstate(1)%phs   , &
               ph     => block%dstate(1)%ph    , &
               ph_lev => block%dstate(1)%ph_lev, &
               gz_lev => block%dstate(1)%gz_lev)
      do k = mesh%full_kds, mesh%full_kde
        do j = mesh%full_jds, mesh%full_jde
          do i = mesh%half_ids, mesh%half_ide
            u(i,j,k) = ueq * mesh%full_cos_lat(j)
          end do
        end do
      end do
      call fill_halo(block%halo, u, full_lon=.false., full_lat=.true., full_lev=.true.)

      do j = mesh%full_jds, mesh%full_jde
        do i = mesh%full_ids, mesh%full_ide
          r = radius * acos(sin(latc) * mesh%full_sin_lat(j) + cos(latc) * mesh%full_cos_lat(j) * cos(mesh%full_lon(i) - lonc))
          gzs(i,j) = g * h0 * exp(-r**2 / d0**2) * cos(pi * r / xi0)**2
        end do
      end do
      call fill_halo(block%halo, gzs, full_lon=.true., full_lat=.true.)

      do j = mesh%full_jds, mesh%full_jde
        do i = mesh%full_ids, mesh%full_ide
          phs(i,j) = peq * exp(-0.5_r8 * ueq**2 / Rd / teq * mesh%full_sin_lat(j)**2 - gzs(i,j) / Rd / teq)
        end do
      end do
      call fill_halo(block%halo, phs, full_lon=.true., full_lat=.true.)

      do k = mesh%half_kds, mesh%half_kde
        do j = mesh%full_jds, mesh%full_jde
          do i = mesh%full_ids, mesh%full_ide
            ph_lev(i,j,k) = vert_coord_calc_ph_lev(k, phs(i,j))
          end do
        end do
      end do
      call fill_halo(block%halo, ph_lev, full_lon=.true., full_lat=.true., full_lev=.false.)

      do k = mesh%full_kds, mesh%full_kde
        do j = mesh%full_jds, mesh%full_jde
          do i = mesh%full_ids, mesh%full_ide
            ph(i,j,k) = 0.5d0 * (ph_lev(i,j,k) + ph_lev(i,j,k+1))
          end do
        end do
      end do
      call fill_halo(block%halo, ph, full_lon=.true., full_lat=.true., full_lev=.true.)

      do k = mesh%full_kds, mesh%full_kde
        do j = mesh%full_jds, mesh%full_jde
          do i = mesh%full_ids, mesh%full_ide
            t(i,j,k) = teq
            pt(i,j,k) = potential_temperature(t(i,j,k), ph(i,j,k), 0.0_r8)
          end do
        end do
      end do
      call fill_halo(block%halo, t , full_lon=.true., full_lat=.true., full_lev=.true.)
      call fill_halo(block%halo, pt, full_lon=.true., full_lat=.true., full_lev=.true.)

      do k = mesh%half_kds, mesh%half_kde
        do j = mesh%full_jds, mesh%full_jde
          do i = mesh%full_ids, mesh%full_ide
            gz_lev(i,j,k) = Rd * teq * log(peq / ph_lev(i,j,k)) - 0.5_r8 * ueq**2 * mesh%full_sin_lat(j)**2
          end do
        end do
      end do
      call fill_halo(block%halo, gz_lev, full_lon=.true., full_lat=.true., full_lev=.false.)
    end associate

  end subroutine ksp15_02_test_set_ic

end module ksp15_test_mod
