#if defined(VERTEX)
#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#else
#define COMPAT_VARYING varying
#define COMPAT_ATTRIBUTE attribute
#endif

COMPAT_ATTRIBUTE vec2 VertexCoord;
COMPAT_ATTRIBUTE vec2 TexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_VARYING vec2 v_tex;
COMPAT_VARYING vec4 v_col;
uniform mat4 MVPMatrix;

uniform float sidePerspective;

void main(void)
{
    vec2 pos = VertexCoord.xy;
    float u = TexCoord.x; // 0.0 = Esquerda, 1.0 = Direita

    // Afunila o lado direito para recuar no fundo 3D
    float rightScale = u * (sidePerspective * 3.5);

    // Reduz a altura do lado direito
    pos.y = (pos.y - 0.5) * (1.0 - rightScale) + 0.5;

    gl_Position = MVPMatrix * vec4(pos, 0.0, 1.0);
    v_tex = TexCoord;
    v_col = COLOR;
}

#elif defined(FRAGMENT)
#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define COMPAT_TEXTURE texture2D
#define FragColor gl_FragColor
#endif
#ifdef GL_ES
precision mediump float;
#endif
uniform sampler2D u_tex;
COMPAT_VARYING vec2 v_tex;
COMPAT_VARYING vec4 v_col;
void main(void)
{
    FragColor = COMPAT_TEXTURE(u_tex, v_tex) * v_col;
}
#endif