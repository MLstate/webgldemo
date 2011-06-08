type mat3 = external;
type glMatrix = external;
type vec3.private = external;

type vec3 = (float, float, float);

mat3 = {{
     str : mat3 -> string = %% glMatrixPlugin.mat3_str %%
     create : -> mat3 = %% glMatrixPlugin.mat3_create %% ;
     transpose : mat3, mat3 -> void = %% glMatrixPlugin.mat3_transpose %% ;
     to_list : mat3 -> list(float) = %% glMatrixPlugin.mat3_to_list %% ;
}}

mat4 = {{
     //to_llarray : glMatrix -> llarray(float) = %% glMatrixPlugin.to_llarray %% ;
     to_list : glMatrix -> list(float) = %% glMatrixPlugin.to_list %% ;
     str : glMatrix -> string = %% glMatrixPlugin.str %%
     create : -> glMatrix = %% glMatrixPlugin.create %% ;
     perspective : float, float, float, float, glMatrix -> void = %% glMatrixPlugin.perspective %% ;
     identity : glMatrix -> void = %% glMatrixPlugin.identity %% ;
     translate : glMatrix, vec3.private, glMatrix -> void = %% glMatrixPlugin.translate %% ;
     lookAt : vec3.private, vec3.private, vec3.private, glMatrix -> void = %% glMatrixPlugin.lookAt %% ;
     multiply : glMatrix, glMatrix, glMatrix -> void = %% glMatrixPlugin.multiply %% ;
     vec3_public_to_private : vec3 -> vec3.private = %% glMatrixPlugin.vec3_public_to_private %% ;
     toInverseMat3 : glMatrix, mat3 -> void = %% glMatrixPlugin.toInverseMat3 %% ;
}}
