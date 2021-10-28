program diag_dress_iter
  implicit none
  BEGIN_DOC
! TODO : Put the documentation of the program here
  END_DOC
  my_grid_becke = .True.
  my_n_pt_r_grid = 30
  my_n_pt_a_grid = 50
  touch  my_grid_becke my_n_pt_r_grid my_n_pt_a_grid
  read_wf = .True.
  touch read_wf 
  call routine

end


subroutine routine
 implicit none
 integer :: i,j
 print*,'eigval_right_tc = ',eigval_right_tc
 print*,'eigval_left_tc  = ',eigval_left_tc
 print*,'******************'
 print*,'< h_core >      = ',h_mono_comp_right_tc
 print*,'< h_eff_2e >    = ',h_eff_comp_right_tc
 print*,'< h_deriv_2_e > = ',h_deriv_comp_right_tc
 print*,'< h_eee >       = ',h_three_comp_right_tc
 print*,'< h_tot >       = ',h_tot_comp_right_tc
 print*,'******************'
 print*,'Left, right and usual eigenvectors '
 do i = 1, N_det
  write(*,'(I5,X,(100(F9.5,X)))')i,leigvec_tc(i,1),reigvec_tc(i,1),psi_coef(i,1)
 enddo
end