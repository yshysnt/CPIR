Implementation of the paper [Contextualized Point-of-Interest Recommendation](https://www.ijcai.org/Proceedings/2020/0344.pdf).
## Preprocessing
In the `preprocess/` directory, run the three Python scripts: `vldb_trans_matlab.py`,`time_stat_vldb.py` and `vldb_user_gt_sim.py`.
## Training
In MATLAB console, run 
```
main2 apg_2obj
```
The result rating matrix will saved (by default) to `processed_data/<dataset_name>/<matrix_name>.mat`
## Configuration
You can change the parameters of the algorithm in `configs0.m`