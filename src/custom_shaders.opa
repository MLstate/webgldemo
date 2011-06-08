
CustomShaders = {{

  shader_fs = "
    #ifdef GL_ES
    precision highp float;
    #endif

    varying vec3 vLightWeighting;

    void main(void) \{
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        gl_FragColor = vec4(vLightWeighting, 1.0);
    }
    " ;

  shader_vs = "
    attribute vec3 aVertexPosition;
    attribute vec3 aVertexNormal;

    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;
    uniform mat3 uNMatrix;

    uniform vec3 uAmbientColor;
    uniform vec3 uLightingDirection;

    uniform bool uUseLighting;

    varying vec3 vLightWeighting;

    void main(void) \{
        gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
        if (uUseLighting) \{
          highp vec3 directionalLightColor = vec3(0.16, 0.16, 0.16);
          vec3 transformedNormal = uNMatrix * aVertexNormal;
          float directionalLightWeighting = max(dot(transformedNormal, uLightingDirection), 0.0);
          vLightWeighting = uAmbientColor + (directionalLightColor * directionalLightWeighting);
        } else \{
          vLightWeighting = uAmbientColor;
        }
    }
    " ;

}}
