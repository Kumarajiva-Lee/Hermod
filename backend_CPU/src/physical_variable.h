#ifndef PHYSICAL_VARIABLE_H_INCLUDED
#define PHYSICAL_VARIABLE_H_INCLUDED 1

#include<stdbool.h>
struct HybridMeshField{ 
  double*** dlat;
  double*** full_lon;
  double*** half_lon;
  double*** full_lat;
  double*** half_lat;
  double*** full_lev;
  double*** half_lev;
  double*** full_cos_lon;
  double*** half_cos_lon;
  double*** full_sin_lon;
  double*** half_sin_lon;
  double*** full_cos_lat;
  double*** half_cos_lat;
  double*** full_sin_lat;
  double*** half_sin_lat;
  double*** full_lon_deg;
  double*** half_lon_deg;
  double*** full_lat_deg;
  double*** half_lat_deg;
  double*** area_cell;
  double*** area_lon;
  double*** area_lon_west;
  double*** area_lon_east;
  double*** area_lon_north;
  double*** area_lon_south;
  double*** area_lat;
  double*** area_lat_west;
  double*** area_lat_east;
  double*** area_lat_north;
  double*** area_lat_south;
  double*** area_vtx;
  double*** area_subcell_0;
  double*** area_subcell_1;
  double*** de_lon;
  double*** de_lat;
  double*** le_lat;
  double*** le_lon;
  double*** full_f;
  double*** half_f;
  double*** full_tangent_wgt_0;
  double*** full_tangent_wgt_1;
  double*** half_tangent_wgt_0;
  double*** half_tangent_wgt_1;
  double*** hyai;
  double*** hybi;
  double*** hyam;
  double*** hybm;
  double*** c_lon;
  double*** c_lat;
};
struct MeshVector6{
  int lx;
  int ly;
  int lz;
  int sx;
  int sy;
  int sz;
};
struct MeshVector3{
    int x;
    int y;
    int z;
};
struct Vector3{
  double x;
  double y;
  double z;
};
struct HybridStateField{ 
  double*** u;
  double*** u_lon;
  double*** u_lat;
  double*** v;
  double*** v_lat;
  double*** v_lon;
  double*** we_lev;
  double*** we_lev_lon;
  double*** we_lev_lat;
  double*** gz;
  double*** gz_lev;
  double*** m;
  double*** m_vtx;
  double*** m_lon;
  double*** m_lat;
  double*** m_lev;
  double*** mfx_lon;
  double*** mfy_lat;
  double*** mfx_lat;
  double*** mfy_lon;
  double*** pv;
  double*** pv_lon;
  double*** pv_lat;
  double*** ke;
  double*** pt;
  double*** ptf_lon;
  double*** ptf_lat;
  double*** ptf_lev;
  double*** t;
  double*** ph;
  double*** ph_lev;
  double*** ph_exn_lev;
  double*** phs;
  double*** div;
  double*** vor;
  double*** qv;
  double*** qm;
  double*** smag_t;
  double*** smag_s;
  double*** kmh;
  double*** kmh_lon;
  double*** kmh_lat;
  double*** q;
  double*** qmf_lon;
  double*** qmf_lat;
  double*** qmf_lev;
  double*** tmpsum;
};
struct HybridStaticField{ 
  double*** gzs;
  double*** dzsdlon;
  double*** dzsdlat;
};
struct HybridAdvField{ 
  double*** old_m;
  double*** mfx;
  double*** mfy;
  double*** mm;
  double*** m0;
  double*** uu;
  double*** u0;
  double*** vv;
  double*** v0;
  double*** we;
  double*** we0;
  double*** cflx;
  double*** cfly;
  double*** cflz;
  double*** divx;
  double*** divy;
  double*** qlx;
  double*** qly;
  double*** dqx;
  double*** dqy;
  double*** q6x;
  double*** q6y;
  double*** qx;
  double*** qy;
  double*** qmf_lon;
  double*** qmf_lat;
  double*** qmf_lev;
};
struct HybridAdvPara{
  bool dynamic;
  int nstep;
  int uv_step;
  int we_step;
  int mf_step;
};
struct Vector4{
  double e0;
  double e1;
  double e2;
  double e3;
};
struct HybridTendField{ 
  double*** du;
  double*** dv;
  double*** dgz;
  double*** dpt;
  double*** dphs;
  double*** qhv;
  double*** qhu;
  double*** dkedlon;
  double*** dkedlat;
  double*** dmfdlon;
  double*** dmfdlat;
  double*** dptfdlon;
  double*** dptfdlat;
  double*** dptfdlev;
  double*** pgf_lon;
  double*** pgf_lat;
  double*** wedudlev;
  double*** wedvdlev;
  double*** smag_dptdt;
  double*** smag_dudt;
  double*** smag_dvdt;
};
struct HybridTendPara{
  bool phs;
  bool pt;
  bool gz;
  bool u;
  bool v;
};
struct Vector2{
  double x;
  double y;
};

struct HybridMeshField mesh[1];
struct HybridMeshField global_mesh[1];
struct HybridStateField state[3];
struct HybridStaticField staticv[1];
struct HybridAdvField adv[2];
struct HybridAdvPara advptPara;
struct HybridTendField tend[2];
struct HybridTendPara tendPara;
struct HybridAdvPara advmPara;

#define async_u 1
#define async_u_lon 2
#define async_u_lat 3
#define async_v 4
#define async_v_lat 5
#define async_v_lon 6
#define async_we_lev 7
#define async_we_lev_lon 8
#define async_we_lev_lat 9
#define async_gz 10
#define async_gz_lev 11
#define async_m 12
#define async_m_vtx 13
#define async_m_lon 14
#define async_m_lat 15
#define async_m_lev 16
#define async_mfx_lon 17
#define async_mfy_lat 18
#define async_mfx_lat 19
#define async_mfy_lon 20
#define async_pv 21
#define async_pv_lon 22
#define async_pv_lat 23
#define async_ke 24
#define async_pt 25
#define async_ptf_lon 26
#define async_ptf_lat 27
#define async_ptf_lev 28
#define async_t 29
#define async_ph 30
#define async_ph_lev 31
#define async_ph_exn_lev 32
#define async_phs 33
#define async_div 34
#define async_vor 35
#define async_qv 36
#define async_qm 37
#define async_smag_t 38
#define async_smag_s 39
#define async_kmh 40
#define async_kmh_lon 41
#define async_kmh_lat 42
#define async_q 43
#define async_qmf_lon 75
#define async_qmf_lat 76
#define async_qmf_lev 77
#define async_tmpsum 47
#define async_gzs 48
#define async_dzsdlon 49
#define async_dzsdlat 50
#define async_old_m 51
#define async_mfx 52
#define async_mfy 53
#define async_mm 54
#define async_m0 55
#define async_uu 56
#define async_u0 57
#define async_vv 58
#define async_v0 59
#define async_we 60
#define async_we0 61
#define async_cflx 62
#define async_cfly 63
#define async_cflz 64
#define async_divx 65
#define async_divy 66
#define async_qlx 67
#define async_qly 68
#define async_dqx 69
#define async_dqy 70
#define async_q6x 71
#define async_q6y 72
#define async_qx 73
#define async_qy 74
#define async_du 78
#define async_dv 79
#define async_dgz 80
#define async_dpt 81
#define async_dphs 82
#define async_qhv 83
#define async_qhu 84
#define async_dkedlon 85
#define async_dkedlat 86
#define async_dmfdlon 87
#define async_dmfdlat 88
#define async_dptfdlon 89
#define async_dptfdlat 90
#define async_dptfdlev 91
#define async_pgf_lon 92
#define async_pgf_lat 93
#define async_wedudlev 94
#define async_wedvdlev 95
#define async_smag_dptdt 96
#define async_smag_dudt 97
#define async_smag_dvdt 98

void PhysicalVariableInit();
void PhysicalVariableFinish();

void LatLonMeshInit_cp(struct HybridMeshField* global_mesh, struct HybridMeshField* mesh);
#endif
