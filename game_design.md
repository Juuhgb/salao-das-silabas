# Design do Jogo: Salão das Sílabas

## Tipo de jogo
Jogo Educacional Casual e Puzzle 2D. Focado na alfabetização infantil lúdica, utilizando interações simples de "apontar e clicar" (point-and-click) ou toque (touch), simulando um ambiente divertido de salão de beleza.

## Mecânica principal
Em cada rodada do jogo, uma **imagem** representativa (ex: um Gato) é exibida no topo da tela. Abaixo da imagem, a palavra correspondente aparece de forma incompleta (ex: "GA - ___"). 

O elemento central da interação é uma **mão com cinco dedos**. Em cada uma das unhas dessa mão, está escrita uma sílaba diferente. Apenas uma das unhas contém a sílaba que falta para completar a palavra da imagem, enquanto as outras quatro funcionam como distratores pedagógicos.
O jogador deve identificar a sílaba correta e **"pintar a unha"** clicando ou tocando nela para completar a palavra.

## Sistema de feedback
*(Abaixo, sugestões criadas para garantir que a percepção de acerto ou erro seja encorajadora e engaje crianças, especialmente as com necessidades especiais)*

*   **Ao Acertar (Feedback Positivo):** 
    *   **Visual:** A unha selecionada é pintada com uma cor vibrante, soltando pequenos confetes ou partículas de brilho. O objeto da imagem de referência pode ter uma pequena animação de alegria.
    *   **Auditivo:** Toca um som muito alegre e suave (ex: som de plim/estrelinhas mágicas). Uma narração de voz amigável repete a sílaba isolada e, em seguida, pronuncia a palavra completa.
*   **Ao Errar (Feedback Construtivo):** 
    *   **Visual:** A unha não se pinta permanentemente; o esmalte "desliza" para fora ou simplesmente não adere, retornando à cor original. Em nenhum momento elementos assustadores ou de punição forte são mostrados (como grandes X vermelhos).
    *   **Auditivo:** Em vez de sons de erro bruscos (como buzinas), será reproduzido um som neutro ou um som lúdico como uma "mola" (boing), incentivando tentar mais uma vez sem gerar ansiedade ou frustração.

## Sistema de progressão
*(Sugestão de desenvolvimento de dificuldade para acompanhar o progresso pedagógico do Método ABACADA)*

O jogo avançará através de **níveis progressivos de dificuldade e um sistema de recompensas lúdico**:

*   **Fases por Complexidade:**
    *   **Nível 1:** Palavras muito curtas (2 sílabas) com sílabas simples (Vogal + Consoante). Ex: Bo-la, Da-do. Os distratores (sílabas nas outras unhas) são foneticamente muito diferentes da resposta certa para evitar confusão.
    *   **Nível 2:** Palavras com 3 sílabas (Ma-ca-co, Ca-be-lo). Os distratores começam a introduzir sílabas sonoras mais parecidas (letra F vs V, P vs B) para exercitar melhor a consciência fonológica.
    *   **Nível 3:** Introdução de sílabas complexas e encontros consonantais (Bra-ço, Lha-ma).
*   **Recompensas e Rotina:** O progresso imediato é marcado pelas unhas da personagem. Como objetivo de curto prazo, o jogador tenta pintar todas as 5 unhas da mão (o que equivale a completar 5 jogos/palavras completas).
*   Ao terminar a "rodada" (5 unhas pintadas), ocorre um momento de celebração e o jogador desbloqueia algo novo no "Salão" (ex: uma pulseira virtual para enfeitar o pulso da mão, um adesivo decorativo e uma cor de esmalte totalmente nova para usar nas próximas rodadas).
