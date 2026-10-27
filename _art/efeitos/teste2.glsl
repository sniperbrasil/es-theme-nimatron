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

    float xCenter = 0.5;
    float yCenter = 0.5;

    // Inclinação lateral original
    float sideOffset = (base.y - yCenter) * side;

    vec2 p;

    // Mantém o efeito lateral
    p.x = base.x + sideOffset;

    // Mantém o topo e o lado direito.
    // Levanta progressivamente a parte inferior esquerda.
    p.y = base.y - (1.0 - base.x) * base.y * backTilt;

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