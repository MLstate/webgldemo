
type vec3.private = external;
type vec3 = (float, float, float);
type vec4.private = external;
type vec4 = (float, float, float, float);

type mat3 = external;
type mat4 = external;

vec3 = {{
     from_public : vec3 -> vec3.private = %% glMatrixPlugin.vec3_private_from_public %% ;
     to_public : vec3.private -> vec3 = %% glMatrixPlugin.vec3_private_to_public %% ;
     str : vec3.private -> string = %% glMatrixPlugin.vec3_str %% ;
}}

vec4 = {{
     from_public : vec4 -> vec4.private = %% glMatrixPlugin.vec4_private_from_public %% ;
     to_public : vec4.private -> vec4 = %% glMatrixPlugin.vec4_private_to_public %% ;
     str : vec4.private -> string = %% glMatrixPlugin.vec4_str %% ;
}}

mat3 = {{
     str : mat3 -> string = %% glMatrixPlugin.mat3_str %%
     create : -> mat3 = %% glMatrixPlugin.mat3_create %% ;
     transpose : mat3, mat3 -> void = %% glMatrixPlugin.mat3_transpose %% ;
     to_list : mat3 -> list(float) = %% glMatrixPlugin.mat3_to_list %% ;
}}

mat4 = {{
     to_list : mat4 -> list(float) = %% glMatrixPlugin.mat4_to_list %% ;
     str : mat4 -> string = %% glMatrixPlugin.mat4_str %%
     create : -> mat4 = %% glMatrixPlugin.mat4_create %% ;
     perspective : float, float, float, float, mat4 -> void = %% glMatrixPlugin.mat4_perspective %% ;
     identity : mat4 -> void = %% glMatrixPlugin.mat4_identity %% ;
     translate : mat4, vec3.private, mat4 -> void = %% glMatrixPlugin.mat4_translate %% ;
     lookAt : vec3.private, vec3.private, vec3.private, mat4 -> void = %% glMatrixPlugin.mat4_lookAt %% ;
     multiply : mat4, mat4, mat4 -> void = %% glMatrixPlugin.mat4_multiply %% ;
     toInverseMat3 : mat4, mat3 -> void = %% glMatrixPlugin.mat4_toInverseMat3 %% ;
     
     inverse : mat4, mat4 -> void = %% glMatrixPlugin.mat4_inverse %% ;
     multiplyVec3 : mat4, vec3.private, vec3.private -> void = %% glMatrixPlugin.mat4_multiplyVec3 %% ;
     copy : mat4 -> mat4 = %% glMatrixPlugin.mat4_copy %% ;
     multiplyVec4 : mat4, vec4.private, vec4.private -> void = %% glMatrixPlugin.mat4_multiplyVec4 %% ;
}}
