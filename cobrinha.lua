-- cobrinha.lua
-- Jogo clássico da Cobrinha

local term = require("term")
local gpu = term.gpu

-- Configuração do jogo
local LARGURA, ALTURA = 51, 19
local LARGURA_JOGO, ALTURA_JOGO = 41, 17
local TAMANHO_INICIAL = 3
local VELOCIDADE = 10  -- Maior = mais lento
local VELOCIDADE_MAXIMA = 20

-- Estado do jogo
local cobrinha = {}
local comida = {}
local direcao = "direita"
local proximaDirecao = "direita"
local pontuacao = 0
local recorde = 0
local gameOver = false
local pausado = false
local nivelVelocidade = 1
local paredes = false

-- Cores (se suportado)
local cores = {
    cobrinha = 0x00FF00,
    cabeca = 0x55FF55,
    comida = 0xFF0000,
    parede = 0x555555,
    texto = 0xFFFFFF
}

-- Inicializar jogo
local function iniciarJogo()
    -- Resetar cobrinha
    cobrinha = {}
    local inicioX = math.floor(LARGURA_JOGO / 2)
    local inicioY = math.floor(ALTURA_JOGO / 2)
    
    for i = TAMANHO_INICIAL, 1, -1 do
        table.insert(cobrinha, {
            x = inicioX - i + 1,
            y = inicioY
        })
    end
    
    -- Gerar primeira comida
    gerarComida()
    
    -- Resetar estado
    direcao = "direita"
    proximaDirecao = "direita"
    pontuacao = 0
    gameOver = false
    pausado = false
    nivelVelocidade = 1
end

-- Gerar comida em posição aleatória
local function gerarComida()
    local posicaoValida = false
    local tentativas = 0
    
    while not posicaoValida and tentativas < 100 do
        comida.x = math.random(1, LARGURA_JOGO)
        comida.y = math.random(1, ALTURA_JOGO)
        
        posicaoValida = true
        
        -- Verificar se não está na cobrinha
        for _, segmento in ipairs(cobrinha) do
            if segmento.x == comida.x and segmento.y == comida.y then
                posicaoValida = false
                break
            end
        end
        
        tentativas = tentativas + 1
    end
end

-- Mover cobrinha
local function moverCobrinha()
    -- Atualizar direção
    direcao = proximaDirecao
    
    -- Calcular nova posição da cabeça
    local cabeca = {x = cobrinha[1].x, y = cobrinha[1].y}
    
    if direcao == "cima" then
        cabeca.y = cabeca.y - 1
    elseif direcao == "baixo" then
        cabeca.y = cabeca.y + 1
    elseif direcao == "esquerda" then
        cabeca.x = cabeca.x - 1
    elseif direcao == "direita" then
        cabeca.x = cabeca.x + 1
    end
    
    -- Verificar colisão com paredes
    if paredes then
        if cabeca.x < 1 or cabeca.x > LARGURA_JOGO or 
           cabeca.y < 1 or cabeca.y > ALTURA_JOGO then
            gameOver = true
            return
        end
    else
        -- Atravessar paredes (modo toroidal)
        if cabeca.x < 1 then cabeca.x = LARGURA_JOGO end
        if cabeca.x > LARGURA_JOGO then cabeca.x = 1 end
        if cabeca.y < 1 then cabeca.y = ALTURA_JOGO end
        if cabeca.y > ALTURA_JOGO then cabeca.y = 1 end
    end
    
    -- Verificar colisão com próprio corpo
    for _, segmento in ipairs(cobrinha) do
        if segmento.x == cabeca.x and segmento.y == cabeca.y then
            gameOver = true
            return
        end
    end
    
    -- Mover cobrinha
    table.insert(cobrinha, 1, cabeca)
    
    -- Verificar se comeu comida
    if cabeca.x == comida.x and cabeca.y == comida.y then
        -- Aumentar pontuação
        pontuacao = pontuacao + 10 * nivelVelocidade
        
        -- Atualizar recorde
        if pontuacao > recorde then
            recorde = pontuacao
        end
        
        -- Aumentar velocidade a cada 50 pontos
        if pontuacao % 50 == 0 and nivelVelocidade < 5 then
            nivelVelocidade = nivelVelocidade + 1
        end
        
        -- Gerar nova comida
        gerarComida()
    else
        -- Remover cauda se não comeu
        table.remove(cobrinha)
    end
end

-- Desenhar tela do jogo
local function desenharTela()
    term.clear()
    
    -- Desenhar cabeçalho
    print(string.rep("=", LARGURA))
    print("         J O G O  D A  C O B R I N H A")
    print(string.rep("=", LARGURA))
    
    -- Desenhar área do jogo
    for y = 0, ALTURA_JOGO + 1 do
        local linha = " "
        
        for x = 0, LARGURA_JOGO + 1 do
            local desenhou = false
            
            -- Desenhar bordas se modo parede estiver ativo
            if paredes and (x == 0 or x == LARGURA_JOGO + 1 or 
                           y == 0 or y == ALTURA_JOGO + 1) then
                linha = linha .. "█"
                desenhou = true
            elseif x == 0 or x == LARGURA_JOGO + 1 or 
                   y == 0 or y == ALTURA_JOGO + 1 then
                linha = linha .. " "
            else
                -- Desenhar cobrinha
                for i, segmento in ipairs(cobrinha) do
                    if segmento.x == x and segmento.y == y then
                        if i == 1 then
                            linha = linha .. "●"  -- Cabeça
                        else
                            linha = linha .. "○"  -- Corpo
                        end
                        desenhou = true
                        break
                    end
                end
                
                -- Desenhar comida
                if not desenhou and comida.x == x and comida.y == y then
                    linha = linha .. "♥"
                    desenhou = true
                end
                
                -- Espaço vazio
                if not desenhou then
                    linha = linha .. " "
                end
            end
        end
        
        -- Desenhar informações à direita
        if y == 1 then
            linha = linha .. "   PONTUAÇÃO: " .. pontuacao
        elseif y == 2 then
            linha = linha .. "   RECORDE: " .. recorde
        elseif y == 3 then
            linha = linha .. "   TAMANHO: " .. #cobrinha
        elseif y == 4 then
            linha = linha .. "   VELOCIDADE: " .. nivelVelocidade .. "/5"
        elseif y == 5 then
            if paredes then
                linha = linha .. "   MODO: PAREDES"
            else
                linha = linha .. "   MODO: SEM PAREDES"
            end
        elseif y == 7 then
            linha = linha .. "   CONTROLES:"
        elseif y == 8 then
            linha = linha .. "   WASD - Movimentar"
        elseif y == 9 then
            linha = linha .. "   P - Pausar"
        elseif y == 10 then
            linha = linha .. "   R - Reiniciar"
        elseif y == 11 then
            linha = linha .. "   M - Mudar modo"
        elseif y == 12 then
            linha = linha .. "   Q - Sair"
        end
        
        print(linha)
    end
    
    -- Mensagem de status
    print(string.rep("-", LARGURA))
    if gameOver then
        print("   GAME OVER! Pressione R para reiniciar")
    elseif pausado then
        print("   JOGO PAUSADO - Pressione P para continuar")
    else
        print("   Controle a cobrinha e coma a comida ♥")
    end
    print(string.rep("=", LARGURA))
end

-- Loop principal do jogo
local function loopJogo()
    iniciarJogo()
    
    local contador = 0
    
    while not gameOver do
        -- Desenhar tela
        desenharTela()
        
        -- Atualizar jogo se não estiver pausado
        if not pausado then
            contador = contador + 1
            
            -- Mover cobrinha na velocidade apropriada
            if contador >= (VELOCIDADA_MAXIMA - nivelVelocidade * 2) then
                moverCobrinha()
                contador = 0
            end
        end
        
        -- Lidar com entrada do usuário
        local event = os.pullEventRaw(0.05)  -- Não-bloqueante
        
        if event == "key" then
            local tecla = os.pullEvent()
            
            if not pausado and not gameOver then
                -- Controles de direção
                if tecla == keys.w or tecla == keys.up then
                    if direcao ~= "baixo" then
                        proximaDirecao = "cima"
                    end
                elseif tecla == keys.s or tecla == keys.down then
                    if direcao ~= "cima" then
                        proximaDirecao = "baixo"
                    end
                elseif tecla == keys.a or tecla == keys.left then
                    if direcao ~= "direita" then
                        proximaDirecao = "esquerda"
                    end
                elseif tecla == keys.d or tecla == keys.right then
                    if direcao ~= "esquerda" then
                        proximaDirecao = "direita"
                    end
                end
            end
            
            -- Controles gerais
            if tecla == keys.p then
                pausado = not pausado
            elseif tecla == keys.r then
                if gameOver then
                    iniciarJogo()
                end
            elseif tecla == keys.m then
                paredes = not paredes
            elseif tecla == keys.q then
                break
            end
            
        elseif event == "terminate" then
            break
        end
    end
    
    -- Tela de game over
    if gameOver then
        while true do
            desenharTela()
            
            local event = os.pullEvent()
            if event == "key" then
                local tecla = os.pullEvent()
                if tecla == keys.r then
                    iniciarJogo()
                    loopJogo()
                    break
                elseif tecla == keys.q then
                    break
                end
            end
        end
    end
end

-- Tela de início
local function telaInicio()
    while true do
        term.clear()
        
        print(string.rep("=", LARGURA))
        print("         J O G O  D A  C O B R I N H A")
        print(string.rep("=", LARGURA))
        print()
        print("  Bem-vindo ao clássico jogo da cobrinha!")
        print("  Controle a cobrinha e coma a comida ♥")
        print("  Cuidado para não bater nas paredes ou")
        print("  em seu próprio corpo!")
        print()
        print(string.rep("-", LARGURA))
        print()
        print("  [1] Iniciar Jogo (Modo Sem Paredes)")
        print("  [2] Iniciar Jogo (Modo Com Paredes)")
        print("  [3] Como Jogar")
        print("  [4] Recorde Atual: " .. recorde)
        print("  [0] Sair")
        print()
        print(string.rep("=", LARGURA))
        
        term.write("  Selecione uma opção: ")
        local escolha = read()
        
        if escolha == "0" then
            print("  Até logo!")
            break
        elseif escolha == "1" then
            paredes = false
            loopJogo()
        elseif escolha == "2" then
            paredes = true
            loopJogo()
        elseif escolha == "3" then
            mostrarInstrucoes()
        elseif escolha == "4" then
            mostrarRecordes()
        end
    end
end

-- Mostrar instruções
local function mostrarInstrucoes()
    term.clear()
    
    print(string.rep("=", LARGURA))
    print("          C O M O  J O G A R")
    print(string.rep("=", LARGURA))
    print()
    print("  OBJETIVO:")
    print("  Controlar a cobrinha para comer a comida ♥")
    print("  e fazer ela crescer o máximo possível!")
    print()
    print("  CONTROLES:")
    print("  W / ↑      - Mover para cima")
    print("  S / ↓      - Mover para baixo")
    print("  A / ←      - Mover para esquerda")
    print("  D / →      - Mover para direita")
    print("  P          - Pausar/Continuar jogo")
    print("  R          - Reiniciar jogo")
    print("  M          - Mudar modo (paredes/sem paredes)")
    print("  Q          - Sair para o menu")
    print()
    print("  MODOS DE JOGO:")
    print("  • Sem Paredes: A cobrinha atravessa as bordas")
    print("  • Com Paredes: Bater na parede é game over")
    print()
    print("  PONTUAÇÃO:")
    print("  • Cada comida: +10 pontos")
    print("  • Bônus de velocidade: +10% por nível")
    print("  • Velocidade aumenta a cada 50 pontos")
    print()
    print(string.rep("=", LARGURA))
    print("  Pressione qualquer tecla para continuar...")
    os.pullEvent("key")
end

-- Mostrar recordes
local function mostrarRecordes()
    term.clear()
    
    print(string.rep("=", LARGURA))
    print("           R E C O R D E S")
    print(string.rep("=", LARGURA))
    print()
    print("  RECORDE ATUAL: " .. recorde)
    print()
    print("  CLASSIFICAÇÃO:")
    print("  ★★★★★  500+ pontos  - Mestre da Cobrinha")
    print("  ★★★★    300-499 pts  - Especialista")
    print("  ★★★     200-299 pts  - Intermediário")
    print("  ★★      100-199 pts  - Iniciante")
    print("  ★       0-99 pts     - Novato")
    print()
    print("  SEU NÍVEL ATUAL: ")
    if recorde >= 500 then
        print("  ★★★★★  MESTRE DA COBRINHA!")
    elseif recorde >= 300 then
        print("  ★★★★  ESPECIALISTA")
    elseif recorde >= 200 then
        print("  ★★★  INTERMEDIÁRIO")
    elseif recorde >= 100 then
        print("  ★★  INICIANTE")
    else
        print("  ★  NOVATO")
    end
    print()
    print("  DICAS:")
    print("  • Faça movimentos previsíveis")
    print("  • Planeje seus caminhos")
    print("  • Use todo o espaço disponível")
    print("  • No modo sem paredes, use as bordas")
    print()
    print(string.rep("=", LARGURA))
    print("  Pressione qualquer tecla para continuar...")
    os.pullEvent("key")
end

-- Versão simples (apenas o jogo básico)
local function jogoSimples()
    print("Jogo da Cobrinha - Versão Simples")
    print("WASD para mover, P para pausar, Q para sair")
    print("Iniciando em 3...")
    os.sleep(1)
    print("2...")
    os.sleep(1)
    print("1...")
    os.sleep(1)
    
    iniciarJogo()
    paredes = false
    
    local contador = 0
    
    while true do
        term.clear()
        
        -- Desenhar jogo simples
        for y = 1, ALTURA_JOGO do
            local linha = ""
            for x = 1, LARGURA_JOGO do
                local desenhou = false
                
                -- Cobrinha
                for i, seg in ipairs(cobrinha) do
                    if seg.x == x and seg.y == y then
                        if i == 1 then
                            linha = linha .. "O"
                        else
                            linha = linha .. "o"
                        end
                        desenhou = true
                        break
                    end
                end
                
                -- Comida
                if not desenhou and comida.x == x and comida.y == y then
                    linha = linha .. "@"
                    desenhou = true
                end
                
                -- Vazio
                if not desenhou then
                    linha = linha .. "."
                end
            end
            print(linha)
        end
        
        print("Pontos: " .. pontuacao .. " | Tamanho: " .. #cobrinha)
        if gameOver then
            print("GAME OVER! Pressione R para reiniciar")
        elseif pausado then
            print("PAUSADO - Pressione P para continuar")
        end
        
        -- Atualizar jogo
        if not pausado and not gameOver then
            contador = contador + 1
            if contador >= VELOCIDADE then
                moverCobrinha()
                contador = 0
            end
        end
        
        -- Controles
        local event = os.pullEventRaw(0.1)
        
        if event == "key" then
            local tecla = os.pullEvent()
            
            if tecla == keys.w and direcao ~= "baixo" then
                proximaDirecao = "cima"
            elseif tecla == keys.s and direcao ~= "cima" then
                proximaDirecao = "baixo"
            elseif tecla == keys.a and direcao ~= "direita" then
                proximaDirecao = "esquerda"
            elseif tecla == keys.d and direcao ~= "esquerda" then
                proximaDirecao = "direita"
            elseif tecla == keys.p then
                pausado = not pausado
            elseif tecla == keys.r and gameOver then
                iniciarJogo()
            elseif tecla == keys.q then
                break
            end
        end
    end
end

-- Iniciar o jogo
print("Carregando Jogo da Cobrinha...")

-- Carregar recorde salvo (se existir)
if fs.exists("cobrinha_recorde.txt") then
    local arquivo = fs.open("cobrinha_recorde.txt", "r")
    recorde = tonumber(arquivo.readLine()) or 0
    arquivo.close()
end

-- Salvar recorde ao sair
local function salvarRecorde()
    local arquivo = fs.open("cobrinha_recorde.txt", "w")
    arquivo.writeLine(tostring(recorde))
    arquivo.close()
end

-- Menu inicial
print("[1] Menu Completo")
print("[2] Jogo Rápido")
print("[3] Sair")

local escolha = read()

if escolha == "1" then
    telaInicio()
    salvarRecorde()
elseif escolha == "2" then
    jogoSimples()
    salvarRecorde()
else
    print("Até logo!")
end
