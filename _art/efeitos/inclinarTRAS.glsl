#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#else
#define COMPAT_VARYING varying
#define COMPAT_ATTRIBUTE attribute
#endif

uniform mat4 MVPMatrix;
COMPAT_ATTRIBUTE vec2 VertexCoord;
COMPAT_ATTRIBUTE vec2 TexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;

// Inclinação lateral opcional. Use 0.0 para somente inclinar para trás.
uniform float side;

COMPAT_VARYING vec2 v_tex;
COMPAT_VARYING vec4 v_col;

void main(void)
{
    vec2 p = VertexCoord;

    // Mantém o paralelogramo opcional já usado no tema.
    p.x += (VertexCoord.y - 0.5) * side;

    gl_Position = MVPMatrix * vec4(p.xy, 0.0, 1.0);
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

// tiltBack: inclinação para trás, em graus.
// perspectiveDepth: profundidade da perspectiva; valores maiores são mais suaves.
uniform float tiltBack;
uniform float perspectiveDepth;
uniform float imageFlipY;

COMPAT_VARYING vec2 v_tex;
COMPAT_VARYING vec4 v_col;

void main(void)
{
    vec2 centered = v_tex - vec2(0.5);

    float angle = radians(tiltBack);
    float depth = max(perspectiveDepth, 0.05);
    float perspective = 0.5 * tan(angle);

    // Perspectiva em torno do eixo horizontal:
    // a parte superior e a parte inferior assumem profundidades diferentes.
    vec2 distorted;
    distorted.x = centered.x /
        (depth + centered.y * perspective) + 0.5;
    distorted.y = centered.y + 0.5;

    // Permite inverter o sentido vertical usado pelo md_image.
    if (imageFlipY > 0.5)
        distorted.y = 1.0 - distorted.y;

    // Fora do quadrilátero perspectivo, deixa transparente.
    if (distorted.x < 0.0 || distorted.x > 1.0 ||
        distorted.y < 0.0 || distorted.y > 1.0)
    {
        FragColor = vec4(0.0);
        return;
    }

    FragColor = COMPAT_TEXTURE(u_tex, distorted) * v_col;
}

#endif
