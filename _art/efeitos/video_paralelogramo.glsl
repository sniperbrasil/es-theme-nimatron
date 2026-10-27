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

// Controlado pelo XML. Mantém a inclinação que já funciona.
uniform float side;

COMPAT_VARYING vec2 v_tex;
COMPAT_VARYING vec4 v_col;

void main(void)
{
    vec2 p;

    // Paralelogramo inclinado para a direita.
    p.x = VertexCoord.x + (VertexCoord.y - 0.5) * side;
    p.y = VertexCoord.y;

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

// Controlados diretamente pelas tags XML.
uniform float lowerLeftLift;
uniform float leftSize;

COMPAT_VARYING vec2 v_tex;
COMPAT_VARYING vec4 v_col;

void main(void)
{
    vec2 distorted = v_tex;

    // No espaço de textura usado pelo efeito que funcionou,
    // y=1 corresponde à parte inferior da imagem.
    // leftSize define a largura horizontal da região afetada:
    // 0.0/1.0 = somente a lateral esquerda;
    // 0.5 = metade esquerda;
    // 1.0 = toda a largura, com efeito diminuindo até a direita.
    float size = max(leftSize, 0.001);
    float leftInfluence = 1.0 - clamp(distorted.x / size, 0.0, 1.0);

    // O efeito começa na base e desaparece em direção ao topo.
    float bottomInfluence = clamp(distorted.y, 0.0, 1.0);
    float lowerLeftWeight = leftInfluence * bottomInfluence;

    // Esta é a mesma operação do shader que apresentou o efeito correto.
    distorted.y += lowerLeftLift * lowerLeftWeight;

    // Fora da textura, deixa transparente; isso forma a quina elevada.
    if (distorted.x < 0.0 || distorted.x > 1.0 ||
        distorted.y < 0.0 || distorted.y > 1.0)
    {
        FragColor = vec4(0.0);
        return;
    }

    FragColor = COMPAT_TEXTURE(u_tex, distorted) * v_col;
}

#endif
