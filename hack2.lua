-- sistema_hack.lua
print("Inicializando sistema de acesso...")

local monitor = peripheral.find("monitor")
local tela = monitor or term
tela.clear()
tela.setBackgroundColor(colors.black)

if monitor then
    monitor.setTextScale(1.2)
end

-- Efeitos visuais de hack
local function efeitoDigitacao(texto, velocidade)
    for i = 1, #texto do
        tela.write(string.sub(texto, i, i))
        sleep(velocidade)
    end
end

local function barraProgresso(duracao, mensagem)
    local largura = 30
    tela.setCursorPos(5, 18)
    tela.setTextColor(colors.cyan)
    tela.write(mensagem)
    
    for i = 1, largura do
        tela.setCursorPos(5 + i, 20)
        tela.setTextColor(colors.green)
        tela.write("█")
        sleep(duracao / largura)
    end
end

local function efeitoMatrix()
    local chars = "01ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    for i = 1, 100 do
        local x = math.random(1, 50)
        local y = math.random(1, 19)
        local char = string.sub(chars, math.random(1, #chars), math.random(1, #chars))
        
        tela.setCursorPos(x, y)
        if math.random(1, 3) == 1 then
            tela.setTextColor(colors.green)
        else
            tela.setTextColor(colors.lime)
        end
        tela.write(char)
    end
end

-- Tela inicial
tela.setTextColor(colors.green)
efeitoDigitacao("╔══════════════════════════════════════╗\n", 0.01)
efeitoDigitacao("║    SISTEMA DE ACESSO REMOTO v3.14    ║\n", 0.03)
efeitoDigitacao("╚══════════════════════════════════════╝\n\n", 0.01)

sleep(1)

tela.setTextColor(colors.cyan)
efeitoDigitacao("Conectando ao servidor principal...\n", 0.05)
barraProgresso(2, "Estabelecendo conexão")

tela.setCursorPos(1, 10)
tela.setTextColor(colors.lime)
efeitoDigitacao("✓ Conexão estabelecida\n", 0.05)

sleep(0.5)

tela.setTextColor(colors.white)
efeitoDigitacao("Procurando vulnerabilidades...\n", 0.05)
barraProgresso(3, "Scanning de portas")

tela.setCursorPos(1, 15)
tela.setTextColor(colors.lime)
efeitoDigitacao("✓ 3 vulnerabilidades encontradas\n", 0.05)

sleep(1)

-- Tela principal do "hack"
tela.clear()
tela.setBackgroundColor(colors.black)

-- Header
tela.setTextColor(colors.red)
tela.setCursorPos(5, 1)
tela.write("╔══════════════════════════════════════════╗")

tela.setCursorPos(5, 2)
tela.setTextColor(colors.red)
tela.write("║   SISTEMA DE CONTROLE - MODO AVANÇADO   ║")

tela.setCursorPos(5, 3)
tela.setTextColor(colors.red)
tela.write("╚══════════════════════════════════════════╝")

-- Menu principal
local opcoes = {
    "1. INVADIR SISTEMA DE DEFESA",
    "2. ACESSAR CAMERAS DE SEGURANÇA", 
    "3. DESATIVAR ALARMES",
    "4. ROUBAR DADOS CONFIDENCIAIS",
    "5. PLANTAR BACKDOOR",
    "6. LIMPAR LOGS",
    "7. SAIR DO SISTEMA"
}

tela.setTextColor(colors.cyan)
for i, opcao in ipairs(opcoes) do
    tela.setCursorPos(10, 5 + i)
    tela.write(opcao)
end

-- Status bar
tela.setTextColor(colors.green)
tela.setCursorPos(5, 19)
tela.write("[CONECTADO] IP: 192.168.1.77 | USUÁRIO: ROOT")

-- Matrix effect no fundo
efeitoMatrix()

-- Interface interativa
local selecionado = 1
local hackeando = false

local function desenharMenu()
    for i, opcao in ipairs(opcoes) do
        tela.setCursorPos(10, 5 + i)
        if i == selecionado and not hackeando then
            tela.setTextColor(colors.yellow)
            tela.write("> " .. opcao)
        else
            tela.setTextColor(colors.cyan)
            tela.write("  " .. opcao)
        end
    end
end

local function simularHack(nome)
    hackeando = true
    tela.clear()
    
    -- Header
    tela.setTextColor(colors.red)
    tela.setCursorPos(10, 2)
    tela.write("EXECUTANDO: " .. nome)
    
    -- Código "hack" rolando
    local codigos = {
        "root@server:~# wget http://malware.exe",
        "root@server:~# chmod +x malware.exe",
        "root@server:~# ./malware.exe --stealth",
        "Injetando código no kernel...",
        "Bypassando firewall...",
        "Criptografando conexão...",
        "Acessando banco de dados...",
        "Copiando arquivos confidenciais...",
        "Deletando logs de acesso..."
    }
    
    for i, codigo in ipairs(codigos) do
        tela.setCursorPos(5, 5 + i)
        if i % 2 == 0 then
            tela.setTextColor(colors.green)
        else
            tela.setTextColor(colors.lime)
        end
        efeitoDigitacao(codigo, 0.1)
        sleep(0.5)
    end
    
    -- Barra de progresso dramática
    tela.setCursorPos(5, 17)
    tela.setTextColor(colors.cyan)
    tela.write("PROGRESSO DO HACK:")
    
    for i = 1, 3 do
        for j = 1, 30 do
            tela.setCursorPos(5 + j, 19)
            if i == 1 then
                tela.setTextColor(colors.red)
            elseif i == 2 then
                tela.setTextColor(colors.yellow)
            else
                tela.setTextColor(colors.green)
            end
            tela.write("█")
            sleep(0.05)
        end
        sleep(0.5)
    end
    
    -- Resultado
    tela.setCursorPos(10, 22)
    tela.setTextColor(colors.lime)
    tela.write("✓ HACK CONCLUÍDO COM SUCESSO!")
    
    sleep(2)
    hackeando = false
    tela.clear()
end

-- Loop principal
while true do
    if not hackeando then
        desenharMenu()
        
        -- Status atualizado
        tela.setTextColor(colors.gray)
        tela.setCursorPos(5, 20)
        tela.write(string.format("SELECIONADO: %s", opcoes[selecionado]:sub(4)))
        
        tela.setTextColor(colors.green)
        tela.setCursorPos(5, 19)
        tela.write("[CONECTADO] IP: 192.168.1." .. math.random(100, 255) .. " | USUÁRIO: ROOT")
    end
    
    local evento = {os.pullEvent()}
    
    if evento[1] == "key" then
        local tecla = evento[2]
        
        if not hackeando then
            if tecla == keys.up then
                selecionado = selecionado - 1
                if selecionado < 1 then selecionado = #opcoes end
            elseif tecla == keys.down then
                selecionado = selecionado + 1
                if selecionado > #opcoes then selecionado = 1 end
            elseif tecla == keys.enter then
                if selecionado == 7 then
                    -- Sair
                    tela.clear()
                    tela.setCursorPos(10, 10)
                    tela.setTextColor(colors.red)
                    tela.write("DESCONECTANDO...")
                    sleep(2)
                    tela.clear()
                    tela.setCursorPos(10, 12)
                    tela.write("CONEXÃO ENCERRADA")
                    sleep(1)
                    break
                else
                    simularHack(opcoes[selecionado]:sub(4))
                end
            end
        end
    end
    
    -- Efeitos visuais aleatórios
    if math.random(1, 10) == 1 and not hackeando then
        efeitoMatrix()
    end
end

tela.clear()
tela.setCursorPos(1, 1)
print("Sistema encerrado.")
