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
    vec2 base = VertexCoord;

    vec2 p;

    // Paralelogramo com medidas preservadas.
    // O único efeito aplicado é a inclinação lateral.
    p.x = base.x + (base.y - 0.5) * side;
    p.y = base.y;

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