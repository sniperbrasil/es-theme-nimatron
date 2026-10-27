#if defined(VERTEX)

uniform mat4 MVPMatrix;

attribute vec2 VertexCoord;
attribute vec2 TexCoord;
attribute vec4 COLOR;

varying vec2 v_tex;
varying vec4 v_col;

uniform float side;
uniform float backTilt;

void main(void)
{
    // Guarda a posição original do vértice
    vec2 base = VertexCoord;

    float xCenter = 0.5;
    float yCenter = 0.5;

    // Deformação lateral
    float sideOffset = (base.y - yCenter) * side;

    // Inclinação para trás
    float tiltOffset = (base.x - xCenter) * backTilt;

    // Aplica os dois efeitos independentemente
    vec2 p;

    p.x = base.x + sideOffset;
    p.y = base.y - tiltOffset;

    gl_Position = MVPMatrix * vec4(p.xy, 0.0, 1.0);

    v_tex = TexCoord;
    v_col = COLOR;
}

#elif defined(FRAGMENT)

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_tex;

varying vec2 v_tex;
varying vec4 v_col;

void main(void)
{
    gl_FragColor = texture2D(u_tex, v_tex) * v_col;
}

#endif