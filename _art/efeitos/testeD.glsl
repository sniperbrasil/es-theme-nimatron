#if defined(VERTEX)

uniform mat4 MVPMatrix;

attribute vec2 VertexCoord;
attribute vec2 TexCoord;
attribute vec4 COLOR;

varying vec2 v_tex;
varying vec4 v_col;

/*
    NIMATRON - Arcade Parallelogram

    side:
        Inclinação lateral. Valores positivos deslocam a parte
        superior para a direita e a inferior para a esquerda.

    backTilt:
        Inclinação vertical. Valores positivos deslocam o lado
        direito para baixo e o esquerdo para cima.

    Os dois efeitos são "shear" (cisalhamento), mantendo a imagem
    como um paralelogramo. Não é rotação 3D real.
*/
uniform float side;
uniform float backTilt;

void main(void)
{
    /*
        O VertexCoord do quad é usado apenas como posição.
        O centro é calculado para que a deformação aconteça
        em torno do centro da imagem.
    */
    vec2 p = VertexCoord;

    /*
        A fórmula abaixo cria um paralelogramo:
        X recebe uma quantidade proporcional ao Y.
    */
    float yCenter = 0.5;
    float xCenter = 0.5;

    p.x += (p.y - yCenter) * side;
    p.y += (p.x - xCenter) * backTilt;

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
