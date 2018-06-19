import os
from OMPython import OMCSessionZMQ
import time
from scipy.optimize import minimize, basinhopping, minimize_scalar, newton, brentq, brenth, bisect
import numpy

#from OMPython import ModelicaSystem

class ModelicaModel:
    def __init__(self, path_file, name, display_errors):
        self.path_file = os.path.abspath(path_file)
        self.path = os.path.dirname(self.path_file)
        self.name = name
        self.display_errors = display_errors
#        os.chdir(self.path)
#        os.chdir("../")
        print("Working directory is " + os.getcwd() + "\n")
        self.stop_time = 0
        self.omc = OMCSessionZMQ()
        print self.omc.sendExpression("getVersion()")
        self.print_err()
        print self.omc.sendExpression("setCommandLineOptions(\"+g=PDEModelica --demoMode=true\")")
        self.print_err()
        print self.omc.sendExpression("loadModel(Modelica)")
        self.print_err()
        print self.omc.sendExpression("loadFile(\"" + path_file + "\")")
        self.print_err()
        #create empty init file for case no parameters will be changed:
        #init_file = open("./WorkingDir/init_file.txt", "w")
        init_file = open("init_file.txt", "w")
        init_file.write("\n")
        init_file.close()

    def print_err(self):
        if self.display_errors:
            print self.omc.sendExpression("getErrorString()")

    def set_stop_time(self, stop_time):
        self.stop_time = stop_time

    def set_parameters(self, param_dict):
        #init_file = open("./WorkingDir/init_file.txt", "w")
        init_file = open("init_file.txt", "w")
        for key in param_dict:
            init_file.write(key + "=" + str(param_dict[key]) + "\n")
        init_file.close()

    def simulate(self):
        #os.chdir("./WorkingDir/")
        simul_str = "simulate(" + self.name + ", stopTime=" + str(self.stop_time) + ", simflags = \"-overrideFile=init_file.txt\")"
        print self.omc.sendExpression(simul_str)
        self.print_err()
        #os.chdir("../")

    def get_var(self, var, t):
        valStr = "val(" + var + " , " + str(t) + ")"
        val = self.omc.sendExpression(valStr)
        self.print_err()
        return val

    def get_var_final(self, var):
        return self.get_var(var, self.stop_time)


class Identification:
    def __init__(self, model, objective_variable, parameters_init_dict, bounds, stop_time):
        self.model = model
        self.objective_variable = objective_variable
        self.parameters = list(parameters_init_dict.keys())
        self.init_values = list(parameters_init_dict.values())
        self.bounds = bounds
        self.model.set_stop_time(stop_time)
        self.neval = 0

    def objective_fun(self, parameter_values):
        param_dict = dict(zip(self.parameters, parameter_values))
        self.model.set_parameters(param_dict)
        self.model.simulate()
        self.neval += 1
        print "Evaluation number " + str(self.neval) + "\n"
        print "Parameters " + str(param_dict) + "\n"

        objective_val = self.model.get_var_final(self.objective_variable)

        print "objectve/root value: " + str(objective_val) + "\n"
        return objective_val

    def objective_fun_scalar(self, parameter):
        return self.objective_fun([parameter])

    def optimize(self):
        init_simplex = numpy.array([[0.1], [0.7]], numpy.float32)
        #return minimize(self.objective_fun, self.init_values, method='Nelder-Mead', tol=1e-6)
        #return basinhopping(self.objective_fun, self.init_values, niter=100, T=1.0, stepsize=0.5)
        #return minimize(self.objective_fun, self.init_values, method='Powell', tol=1e-6)
        return minimize_scalar(self.objective_fun_scalar, bounds=self.bounds, method='bounded')
        #return minimize_scalar(self.objective_fun_scalar, bracket=[0.0, 0.5, 1.0], method='brent')

    def findRoot(self):
        #return newton(self.objective_fun_scalar, self.init_values[0])
        return brentq(self.objective_fun_scalar, self.bounds[0], self.bounds[1])

def save_and_print_results(file_name, model_name, parameter_names, objective_variable, results, ident_type):
    if ident_type == 0:
        p_val = results["x"]
    else:
        p_val = results
    file_name_txt = "./Identification/Results/" + os.path.splitext(os.path.basename(file_name))[0] + "_" + model_name + ".txt"
    with open(file_name_txt, "a") as f:
        f.write("Time:\t" + str(time.ctime()) + "\n")
        f.write("Model file:\t" + file_name + "\n")
        f.write("Model:\t" + model_name + "\n")
        f.write("Objective:\t" + objective_variable + "\n")
        f.write("Results:\n" + str(results) + "\n")
        print("Results:\n" + str(results) + "\n")
        if isinstance(p_val, list):
            for i in range(len(p_val)):
                f.write(parameter_names[i] + " = " + str(p_val[i]) + "\n")
                print(parameter_names[i] + " = " + str(p_val[i]) + "\n")
        else:
            f.write(parameter_names[0] + " = " + str(p_val) + "\n")
            print(parameter_names[0] + " = " + str(p_val) + "\n")
        f.write("\n------------------------------------------------------------\n\n\n")
    f.close()


def complete_identification(model_file, model_name, objective_variable, parameters_init_dict, bounds, stop_time, ident_type):
    model_file_abs = os.path.abspath(model_file)
    display_errors = True
    wdir = "./WorkingDir/" + model_name + "_" + str(time.time())
    os.makedirs(wdir)
    os.chdir(wdir)


    model = ModelicaModel(model_file_abs, model_name, display_errors)
    identification = Identification(model, objective_variable, parameters_init_dict, bounds, stop_time)
    if ident_type == 0:
        results = identification.optimize()
    else:
        results = identification.findRoot()
    os.chdir("../../")
    save_and_print_results(model_file, model_name, parameters_init_dict.keys(), objective_variable, results, ident_type)
    if ident_type == 0:
        x = results["x"]
    else:
        x = results
    return x




#dumping_model_identification()

#print complete_identification("../Dumping.mo", "Dumping", "y", {"k": 1}, 10)

#print complete_identification("../SnowBreathing/package.mo", "SnowBreathing.Models.c013_12s2000_snow", "coneCompGrad.RMSCO2", {"coneCompGrad.D_CO2": 3.0e-4}, 800)
#print complete_identification("advection.mo", "advection", "uu", {"c": 0.45}, [0.0, 1.0], 1, 0)
#print complete_identification("advection.mo", "advection", "uuRoot", {"c": 0.45}, [0.0, 1.0], 1, 1)
#print complete_identification("../SnowBreathing/package.mo", "SnowBreathing.Models.c004_8S2000_snow", "virtualCavity.ErrCO2", {"coneCompGrad.D_CO2": 3.0e-3}, [1.0e-5, 1.0e-2], 686, 1) #D_CO2 = 7.23161687077e-4
#print complete_identification("../SnowBreathing/package.mo", "SnowBreathing.Models.c004_8S2000_snow", "virtualCavity.ErrO2", {"coneCompGrad.D_O2": 3.0e-3}, [1.0e-5, 1.0e-2], 686, 1) #D_O2 = 7.25139213663e-4
#print complete_identification("../SnowBreathing/package.mo", "SnowBreathing.Models.c013_12s2000_snow", "virtualCavity.ErrCO2", {"coneCompGrad.D_CO2": 3.0e-3}, [1.0e-5, 1.0e-2], 611, 1)
#print complete_identification("../SnowBreathing/package.mo", "SnowBreathing.Models.c004_11m2000_snow", "virtualCavity1.ErrO2", {"coneCompGrad1.D_O2": 3.0e-3}, [1.0e-5, 1.0e-2], 322, 1) #D_O2 =4.48799322137e-4
#print complete_identification("../SnowBreathing/package.mo", "SnowBreathing.Models.c004_11m2000_snow", "virtualCavity1.ErrCO2", {"coneCompGrad1.gamma": 1.0}, [0.0, 5.0], 255, 1) # gamma = 0.00803050238894
#bezi: print complete_identification("../SnowBreathing/package.mo", "SnowBreathing.Models.c004_11m2000_snow", "virtualCavity1.ErrCO2", {"coneCompGrad1.gamma": 1.0}, [5.0, 30.0], 255, 1) # gamma = 6.76639037717

