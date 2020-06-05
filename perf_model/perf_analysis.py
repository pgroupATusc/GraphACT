import numpy as np
import sys,math


class perf_analysis:
	def __init__(self,RDSP,RBRAM,RDDR):
		"""
		Define the resources of the target FPGA

		Inputs:
			RDSP (int)			total num of DSP slices on-chip
			RBRAM (float)		total BRAM size (in mega bits)
			RDDR (float)		total off-chip bandwidth (in GB/s)
		Output:
			None
		"""
		self.RDSP = RDSP
		self.RBRAM = RBRAM
		self.RDDR = RDDR
		self.dim_hid = None
		self.dim_class = None
		self.dim_node = None
		self.reset()

	def set_hardware_spec(self,FREQ,COST_word,COST_mult,COST_add,COST_mac):
		"""
		Specify the key cost values for the target accelerator

		Inputs:
			FREQ (float)		expected frequency (in MHz)
			COST_word (int)		num bit per word (e.g., for single precision 
								floating point, this value = 32)
			COST_mult (int)		num of DSP slices to implement one multiplier
			COST_add (int)		num of DSP slices to implement one adder
			COST_mac (int)		num of DSP slices to implement one MAC
		Output:
			None
		"""
		self.FREQ = FREQ
		self.COST_word = COST_word
		self.COST_mult = COST_mult
		self.COST_add = COST_add
		self.COST_mac = COST_mac

	def set_GNN_spec(self,L,dim_hid,num_epoch):
		"""
		Specify the GNN architecture and training parameters

		Inputs:
			L (int)				num of graph conv layers
			dim_hid (int)		hidden dimension of graph conv layers
			num_epoch (int)		estimated num of epochs till convergence
		Output:
			None
		"""
		self.L = L
		self.dim_hid = dim_hid
		self.num_epoch = num_epoch
		if self.dim_node:
			self.dim_all_l = [self.dim_node]+[self.dim_hid]*self.L+[self.dim_class]

	def set_graph_spec(self,V,gamma,beta,dim_node,dim_class):
		"""
		Specify the graph parameters

		Inputs:
			V (int)				num training nodes
			gamma (float)		redundancy reduction ratio
			beta (float)		overhead in storing the partial sum
			dim_node (int)		dim of initial node feature
			dim_class (int)		num classes
		Output:
			None
		"""
		self.V = V
		self.gamma, self.beta = gamma, beta
		self.dim_node, self.dim_class = dim_node, dim_class
		if self.dim_hid:
			self.dim_all_l = [self.dim_node]+[self.dim_hid]*self.L+[self.dim_class]

	def set_design(self,Psys,Pagg,Vsub,dsub):
		"""
		Set the design parameters of the architecture

		Inputs:
			Psys (int)			dim of systolic array
			Pagg (int)			dim of feat aggr array
			Vsub (int)			size of the sampled subgraph
		Output:
			None
		"""
		self.Psys, self.Pagg = Psys, Pagg
		self.Vsub, self.dsub = Vsub, dsub

	def ret_design(self):
		return self.Psys, self.Pagg, self.Vsub, self.dsub

	def reset(self):
		# self.dim_hid = None
		# self.dim_class = None
		# self.dim_node = None
		self.Psys = None
		self.Pagg = None
		self.Vsub = None
		self.dsub = None

	def _consumption_BRAM(self):
		"""
		Compute the consumption of on-chip BRAM
		
		Inputs:
			None
		Output:
			None
		"""
		try:
			_buf_weight = 2*(self.L+1)*self.dim_hid**2
		except Exception:
			import pdb; pdb.set_trace()
		_buf_WT = self.Psys*self.Vsub
		# size of buffer for storing the partial sum
		_dim_max = max(self.dim_hid,self.dim_node,self.dim_class)
		_buf_partial_agg = _dim_max*self.beta*self.Vsub
		# buffer to store the grad wrt X (to back-prop to prev layer)
		_buf_grad_X = 2*max(self.dim_hid,self.dim_class)*self.Vsub
		_buf_X = sum([f*self.Vsub for f in self.dim_all_l])
		_buf_inter = _dim_max*self.Vsub
		self.buf_actual = _buf_weight+_buf_WT+_buf_partial_agg+_buf_grad_X+_buf_inter
		# buf_pred = (self.L+5)*self.dim_hid*self.Vsub \
		# 		 + self.dim_hid*self.beta*self.Vsub \
		# 		 + self.Psys*self.Vsub + 2*(self.L+1)*self.dim_hid**2
	    
	def _consumption_DSP(self):
		self.dsp_actual = self.Pagg*self.COST_add + self.Psys**2*self.COST_mac

	def is_feasible(self):
		self._consumption_BRAM()
		self._consumption_DSP()
		#import pdb; pdb.set_trace()
		return (self.buf_actual < self.RBRAM/self.COST_word*1e6) \
		   and (self.dsp_actual < self.RDSP) \
		   and (self.Pagg <= self.dim_hid)

	def cycle_batch(self):
		# forward prop: one aggr + two matmul per graph conv layer
		t_agg_forward = [int(self.Vsub*self.dsub*self.gamma*math.ceil(f/self.Pagg)\
				      + math.ceil(self.Vsub/self.Psys)*f) for f in self.dim_all_l[:-2]]
		t_sys_forward_half = [int(math.ceil(0.5*self.dim_all_l[l+1]/self.Psys)\
					  * self.dim_all_l[l] * math.ceil(self.Vsub/self.Psys)) for l in range(self.L)]
		t_forward = [max(t_agg_forward[l],t_sys_forward_half[l])+t_sys_forward_half[l] for l in range(self.L)]
		t_forward.append(self.dim_all_l[-2]*math.ceil(self.dim_all_l[-1]/self.Psys)*math.ceil(self.Vsub/self.Psys))
		# backward prop: two aggr + four matmul per graph conv layer
		t_agg_backward_1 = [int(self.Vsub*self.dsub*self.gamma*math.ceil(f/self.Pagg) 
	    	 			 + math.ceil(f/self.Psys)*self.Vsub) for f in self.dim_all_l[:-2]]
		t_agg_backward_2 = [int(self.Vsub*self.dsub*self.gamma*math.ceil(0.5*f/self.Pagg)) for f in self.dim_all_l[2:-1]]
		t_sys_backward_w_half = [int(math.ceil(0.5*self.dim_all_l[l+1]/self.Psys)\
	    					  * math.ceil(self.dim_all_l[l]/self.Psys)*self.Vsub) for l in range(self.L)]
		t_sys_backward_x_half = [int(0.5*self.dim_all_l[l+2]*math.ceil(self.Vsub/self.Psys)\
	    					  * math.ceil(self.dim_all_l[l+1]/self.Psys)) for l in range(self.L-1)]
		t_backward = [max(t_agg_backward_1[l],t_sys_backward_w_half[l])+t_sys_backward_w_half[l] for l in range(self.L)]\
	               + [max(t_agg_backward_2[l],t_sys_backward_x_half[l])+t_sys_backward_x_half[l] for l in range(self.L-1)]
		t_backward.append(math.ceil(self.dim_all_l[-1]/self.Psys)*math.ceil(self.dim_all_l[-2]/self.Psys)*self.Vsub)
		t_backward.append(math.ceil(self.Vsub/self.Psys)*math.ceil(self.dim_all_l[-1]/self.Psys)*self.dim_all_l[-2])
		# forward and backward prop
		t_total = sum(t_forward) + sum(t_backward)
		return t_total

	def time_converge(self, cyc_bat):
		return cyc_bat/(self.FREQ*1e6)*math.ceil(self.V/self.Vsub)*self.num_epoch

	def ops_total(self):
		ops_agg_forward = [int(self.gamma*self.Vsub*self.dsub*f) for f in self.dim_all_l[:-2]]
		ops_sys_forward = [2*self.Vsub*self.dim_all_l[l]*self.dim_all_l[l+1] for l in range(self.L+1)]
		ops_agg_backward_1 = [int(self.Vsub*self.dsub*self.gamma*f) for f in self.dim_all_l[:-2]]
		ops_agg_backward_2 = [int(self.Vsub*self.dsub*self.gamma*0.5*f) for f in self.dim_all_l[2:-1]]
		ops_sys_backward_1 = [2*self.Vsub*self.dim_all_l[l]*self.dim_all_l[l+1] for l in range(self.L+1)]
		ops_sys_backward_2 = [2*self.Vsub*self.dim_all_l[l+1]*self.dim_all_l[l+2] for l in range(self.L-1)]
		return sum(ops_agg_forward)+sum(ops_sys_forward)\
	    	 + sum(ops_agg_backward_1)+sum(ops_agg_backward_2)\
	    	 + sum(ops_sys_backward_1)+sum(ops_sys_backward_2)




def DSE():
	RDSP, RBRAM, RDDR = 5760, 229, 0
	pa = perf_analysis(RDSP, RBRAM, RDDR)
	FREQ, COST_word, COST_mult, COST_add, COST_mac = 200, 32, 1, 1, 2
	pa.set_hardware_spec(FREQ, COST_word, COST_mult, COST_add, COST_mac)
	L, dim_hid, num_epoch = 2, 256, 10
	pa.set_GNN_spec(L, dim_hid, num_epoch)
	V, gamma, beta, dim_node, dim_class = int(716847*0.66), 0.7, 1, 300, 100
	pa.set_graph_spec(V, gamma, beta, dim_node, dim_class)
	Psys_bound = int((RDSP/COST_mac)**0.5)
	best_design = None
	min_time = float('inf')
	for _ps in range(1,Psys_bound):
		for _pa in range(16,dim_hid,16):
			for _vs in range(500,8000,500):
				pa.reset()
				pa.set_design(_ps,_pa,_vs,15)
				if not pa.is_feasible():
					continue
				_cyc = pa.cycle_batch()
				_time = pa.time_converge(_cyc)
				if _time < min_time:
					min_time = _time
					best_design = pa.ret_design()
	print("Best design: Psys = {}\tPaggr = {}\tVsub = {}\tdsub = {}"\
			.format(*best_design))
	print("Convergence time: {}".format(min_time))


if __name__ == "__main__":
	DSE()