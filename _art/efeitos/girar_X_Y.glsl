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

COMPAT_VARYING vec2 v_tex;
COMPAT_VARYING vec4 v_col;

void main(void)
{
    // Mantém o quad original. A deformação ocorre no fragment shader.
    gl_Position = MVPMatrix * vec4(VertexCoord.xy, 0.0, 1.0);
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

// Estes nomes precisam ser iguais às tags dentro de <shader> no XML.
uniform float tiltAngle;
uniform float tiltAngleX;
uniform float perspectiveDepth;
uniform float lowerLeftLift;

COMPAT_VARYING vec2 v_tex;
COMPAT_VARYING vec4 v_col;

void main(void)
{
    float angleY = radians(tiltAngle);
    float angleX = radians(tiltAngleX);
    float depth = max(perspectiveDepth, 0.05);

    float perspectiveY = 0.5 * tan(angleY);
    float perspectiveX = 0.5 * tan(angleX);

    vec2 centered = v_tex - vec2(0.5);

    // Mesmo cálculo de perspectiva do Angled_border_gradient.glsl.
    vec2 distorted;
    distorted.x = centered.x /
        (depth + centered.y * perspectiveY) + 0.5;
    distorted.y = centered.y /
        (depth + centered.x * perspectiveX) + 0.5;

    // A coordenada y=1 é considerada a parte inferior da textura.
    // A elevação atua apenas na quina inferior esquerda:
    //   x=0,y=1 -> efeito máximo
    //   x=1,y=1 -> efeito zero
    //   x=0,y=0 -> efeito zero
    float leftWeight = 1.0 - clamp(distorted.x, 0.0, 1.0);
    float bottomWeight = clamp(distorted.y, 0.0, 1.0);
    float cornerWeight = leftWeight * bottomWeight;

    distorted.y += lowerLeftLift * cornerWeight;

    // A região fora do quadrilátero fica transparente.
    if (distorted.x < 0.0 || distorted.x > 1.0 ||
        distorted.y < 0.0 || distorted.y > 1.0)
    {
        FragColor = vec4(0.0);
        return;
    }

    FragColor = COMPAT_TEXTURE(u_tex, distorted) * v_col;
}

#endif
