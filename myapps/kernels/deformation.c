//Inverse Twist Transformation Functions
float3 twist_inv(float3 p, float k) {
    float3 result;
    float theta = k * p.z;
    float C = cos(theta);
    float S = sin(theta);
    result.x = p.x * C + p.y * S;
    result.y = -p.x * S + p.y * C;
    result.z = p.z;
    return result;
}

float3 twist_normal(float3 p, float3 n, float k) {
    float3 result;
    float theta = k * p.z;
    float C = cos(theta);
    float S = sin(theta);
    result.x = n.x * C - n.y * S;
    result.y = n.x * S + n.y * C;
    result.z = (p.y * k) * n.x - (p.x * k) * n.y + n.z;
    return result;
}
//Inverse Twist Transformation Functions

//Inverse Taper Transformation Functions
float taperFunction(float x, float max_x, float min_x, int t_func){
	if(t_func == 0){
		return (1/((x * x) + 1));
	} else if(t_func == 1){
		return ((x * x) + 1);
	} else if(t_func == 2){
		return (max_x - x)/(max_x - min_x);
	}

	return 0.0f;
}

float taperDerFunction(float x, float max_x, float min_x, int t_func){
	if(t_func == 0){
		float d = (x * x) + 1;
		return -((2 * x)/(d * d));
	} else if(t_func == 1){
		return 2 * x;
	} else if(t_func == 2){
		return 1/(min_x - max_x);
	}

	return 0.0f;
}

float3 taper_inv(float3 p, float max_, float min_, int t_func){
	float3 result;
	float r = taperFunction(p.z, max_, min_, t_func);
	
	result.x = p.x/r;
	result.y = p.y/r;
	result.z = p.z;
	
	return result;
}

float3 taper_normal(float3 p, float3 n, float max_, float min_, int t_func){
    float3 result;
	float r = taperFunction(p.z, max_, min_, t_func);
	float t = taperDerFunction(p.z, max_, min_, t_func);
	
	result.x = n.x * r;
	result.y = n.y * r;
	result.z = ((-r * t * p.x) * n.x) + ((-r * t * p.y) * n.y) + (r * r * n.z);
	
    return result;
}
//Inverse Taper Transformation Functions

//Inverse Bend Transformation Functions
float3 bend_inv(float3 p, float max_, float min_, float y_zero, float k){
	float3 result;
	
	float x = p.x;
	float y = p.y;
	float z = p.z;
	
	float range = 1.0f/k;
	
	float theta_min = k * (min_ * y_zero);
	float theta_max = k * (max_ * y_zero);
	
	float f_sen = y - y_zero;
	float s_sen = z - range;
	
	
	float m_t = f_sen/s_sen;
	
	float theta_tan = -atan(m_t);
	
	float theta;
	
	if(theta_tan < theta_min){
		theta = theta_min;
	} else if(theta_min <= theta_tan && theta_tan <= theta_max){
		theta = theta_tan;
	} else if(theta_tan > theta_max){
		theta = theta_max;
	}
	
	float C = cos(theta);
    float S = sin(theta);
	
	float y_ = (theta/k) + y_zero;
	
	float Y_F;
	float Z_F;
	
	if(min_ < y_ && y_ < max_){
		Y_F = y_;
		
		float t_sen = (f_sen * f_sen) + (s_sen * s_sen); 		
		Z_F = range + pow(t_sen, 0.5f);
	} else if(y_ == min_ || y_ == max_){
		Y_F = f_sen * C + s_sen * S + y_;
		Z_F =-f_sen * S + s_sen * C + y_;
	}
	
	result.x = x;
	result.y = Y_F;
	result.z = Z_F;
	
	return result;
}

float3 bend_normal(float3 p, float3 n, float max_, float min_, float y_zero, float k){
	float3 result;
	
	float x = p.x;
	float y = p.y;
	float z = p.z;
	
	float theta;
	float y_;
	
	if(y <= min_){
		y_ = min_;
	} else if(min_ < y && y < max_){
		y_ = y;
	} else if(y >= max_){
		y_ = max_;
	}
		
	theta = k * (y_ - y_zero);
	
	float C = cos(theta);
    float S = sin(theta);
	
	float k_ = (y_ == y)? k : 0;
	
	float l_r_e = 1 - k_ * z;
	
	float n_x = n.x;
	float n_y = n.y;
	float n_z = n.z;
	
	result.x = n_x * l_r_e;
	result.y = (n_y * C) + (n_z * -S * l_r_e);
	result.z = (n_y * S) + (n_z * C * l_r_e);
	
	return result;
}