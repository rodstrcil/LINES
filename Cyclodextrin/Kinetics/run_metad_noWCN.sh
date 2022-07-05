i=1
while [ $i -le 100 ]
do
output_file=md_run_noWCN${i}

cat >plumed.dat << EOF
FIT_TO_TEMPLATE reference=../conf_ref.pdb TYPE=OPTIMAL
WHOLEMOLECULES ENTITY0=1-147 ENTITY1=148-160
com0: COM ATOMS=1-147
com1: COM ATOMS=148-160
dist_rest: DISTANCE ATOMS=com1,com0 COMPONENTS
uwall: UPPER_WALLS ARG=dist_rest.z,dist_rest.y,dist_rest.x AT=1.5,0.4,0.4 KAPPA=500.0,500.0,500.0
lwall: LOWER_WALLS ARG=dist_rest.z,dist_rest.y,dist_rest.x AT=-1.5,-0.4,-0.4 KAPPA=500.0,500.0,500.0
CV0: DISTANCE ATOMS=com1,com0 COMPONENTS

metad: METAD ...
        ARG=CV0.z SIGMA=0.05 HEIGHT=0.3 PACE=10000 GRID_MIN=-1 GRID_MAX=1 GRID_BIN=60
        GRID_WFILE=grid.dat GRID_WSTRIDE=10000 CALC_RCT
...

PRINT ARG=CV0.z,metad.* FILE=${output_file}.txt STRIDE=25
EOF

gmx grompp -f ../md.mdp -c ../md_config_start.gro -t ../md_config_start.cpt -p ../topol.top -o ${output_file}.tpr -maxwarn 1
mpirun gmx_mpi mdrun -deffnm ${output_file} -plumed plumed.dat
i=$((${i}+1))
done
