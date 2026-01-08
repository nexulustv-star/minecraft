-- sistema_hack_avancado.lua
print("Inicializando sistema de acesso avançado...")

local monitor = peripheral.find("monitor")
local tela = monitor or term
tela.clear()
tela.setBackgroundColor(colors.black)

if monitor then
    monitor.setTextScale(1.2)
end

-- Dados dos alvos
local alvos = {
    ["Richi"] = {
        ip = "192.168.1.101",
        sistema = "Windows 11 Pro",
        vulnerabilidades = {"CVE-2023-24932", "CVE-2023-23397"},
        dados = {
            banco = "Banco do Brasil - Ag 1234",
            facebook = "richi_gamer",
            whatsapp = "+55 19 98765-4321",
            email = "richi.pro@gmail.com"
        }
    },
    ["qft"] = {
        ip = "192.168.1.102", 
        sistema = "Linux Ubuntu 22.04",
        vulnerabilidades = {"CVE-2023-32629", "CVE-2023-29491"},
        dados = {
            banco = "Nubank - ****1234",
            facebook = "qft_oficial",
            whatsapp = "+55 11 91234-5678",
            email = "qft@protonmail.com"
        }
    },
    ["bot_jv"] = {
        ip = "192.168.1.103",
        sistema = "Android 13",
        vulnerabilidades = {"CVE-2023-35674", "CVE-2023-33177"},
        dados = {
            banco = "Inter - ****4321",
            facebook = "jv_bot",
            whatsapp = "+55 21 99876-5432",
            email = "bot.jv@yahoo.com"
        }
    }
}

-- Efeitos visuais
local function efeitoDigitacao(texto, velocidade, cor)
    tela.setTextColor(cor or colors.green)
    for i = 1, #texto do
        tela.write(string.sub(texto, i, i))
        sleep(velocidade)
    end
end

local function barraProgresso(duracao, mensagem, cor)
    local largura = 30
    tela.setCursorPos(5, 18)
    tela.setTextColor(cor or colors.cyan)
    tela.write(mensagem)
    
    for i = 1, largura do
        tela.setCursorPos(5 + i, 20)
        tela.setTextColor(colors.green)
        tela.write("█")
        sleep(duracao / largura)
    end
end

-- Tela inicial
tela.setTextColor(colors.green)
efeitoDigitacao("╔══════════════════════════════════════════╗\n", 0.01)
efeitoDigitacao("║   SISTEMA DE HACK AVANÇADO - v5.20      ║\n", 0.03)
efeitoDigitacao("╚══════════════════════════════════════════╝\n\n", 0.01)

sleep(1)

tela.setTextColor(colors.cyan)
efeitoDigitacao("Carregando módulos de ataque...\n", 0.05)
barraProgresso(2, "Inicializando payloads", colors.blue)

tela.setCursorPos(1, 10)
tela.setTextColor(colors.lime)
efeitoDigitacao("✓ Módulos carregados: 7/7\n", 0.05)

sleep(0.5)

tela.setTextColor(colors.white)
efeitoDigitacao("Escaneando rede local...\n", 0.05)
barraProgresso(3, "Detectando dispositivos", colors.cyan)

-- Mostrar alvos encontrados
tela.setCursorPos(1, 15)
tela.setTextColor(colors.lime)
efeitoDigitacao("✓ ALVOS DETECTADOS:\n", 0.05)

local linha = 16
for nome, info in pairs(alvos) do
    tela.setCursorPos(3, linha)
    tela.setTextColor(colors.yellow)
    tela.write("• " .. nome .. " - " .. info.ip .. " (" .. info.sistema .. ")")
    linha = linha + 1
    sleep(0.3)
end

sleep(2)

-- Tela de seleção de alvo
local alvoSelecionado = nil
local modoSelecionado = nil

local function telaSelecaoAlvo()
    tela.clear()
    
    -- Header
    tela.setTextColor(colors.red)
    tela.setCursorPos(5, 1)
    tela.write("╔══════════════════════════════════════════╗")
    tela.setCursorPos(5, 2)
    tela.write("║   SELECIONE O ALVO                       ║")
    tela.setCursorPos(5, 3)
    tela.write("╚══════════════════════════════════════════╝")
    
    -- Lista de alvos
    local opcoesAlvos = {}
    local i = 1
    for nome, info in pairs(alvos) do
        opcoesAlvos[i] = nome
        tela.setCursorPos(10, 5 + i)
        if alvoSelecionado == nome then
            tela.setTextColor(colors.yellow)
            tela.write("> " .. nome .. " - " .. info.ip)
        else
            tela.setTextColor(colors.cyan)
            tela.write("  " .. nome .. " - " .. info.ip)
        end
        i = i + 1
    end
    
    -- Informações do alvo selecionado
    if alvoSelecionado then
        local info = alvos[alvoSelecionado]
        tela.setCursorPos(5, 12)
        tela.setTextColor(colors.white)
        tela.write("SISTEMA: " .. info.sistema)
        
        tela.setCursorPos(5, 13)
        tela.setTextColor(colors.orange)
        tela.write("VULNERABILIDADES: " .. table.concat(info.vulnerabilidades, ", "))
        
        tela.setCursorPos(5, 15)
        tela.setTextColor(colors.lime)
        tela.write("Pressione ENTER para selecionar este alvo")
    end
    
    -- Status
    tela.setTextColor(colors.green)
    tela.setCursorPos(5, 19)
    tela.write("[ESCANEANDO] Dispositivos ativos: " .. #opcoesAlvos)
end

local function telaModosAtaque()
    tela.clear()
    
    -- Header
    tela.setTextColor(colors.red)
    tela.setCursorPos(5, 1)
    tela.write("╔══════════════════════════════════════════╗")
    tela.setCursorPos(5, 2)
    tela.write("║   MODO DE ATAQUE - " .. string.upper(alvoSelecionado) .. "             ║")
    tela.setCursorPos(5, 3)
    tela.write("╚══════════════════════════════════════════╝")
    
    -- Modos de ataque
    local modos = {
        "1. ROUBAR DADOS BANCÁRIOS",
        "2. INVADIR FACEBOOK",
        "3. CLONAR WHATSAPP",
        "4. ROUBAR EMAILS",
        "5. ACESSO REMOTO TOTAL",
        "6. VOLTAR AO MENU ANTERIOR"
    }
    
    for i, modo in ipairs(modos) do
        tela.setCursorPos(10, 5 + i)
        if modoSelecionado == i then
            tela.setTextColor(colors.yellow)
            tela.write("> " .. modo)
        else
            tela.setTextColor(colors.cyan)
            tela.write("  " .. modo)
        end
    end
    
    -- Descrição do modo selecionado
    if modoSelecionado then
        local descricoes = {
            "Extrair informações de contas bancárias e cartões",
            "Obter acesso completo ao perfil do Facebook",
            "Clonar número do WhatsApp e acessar conversas",
            "Roubar emails e contas associadas",
            "Acesso root/administrador completo ao sistema",
            "Voltar para seleção de alvo"
        }
        
        tela.setCursorPos(5, 15)
        tela.setTextColor(colors.white)
        tela.write("DESCRIÇÃO: " .. descricoes[modoSelecionado])
    end
    
    -- Status
    tela.setTextColor(colors.green)
    tela.setCursorPos(5, 19)
    tela.write("ALVO: " .. alvoSelecionado .. " | IP: " .. alvos[alvoSelecionado].ip)
end

local function executarAtaque()
    tela.clear()
    
    local info = alvos[alvoSelecionado]
    local modoNomes = {"DADOS BANCÁRIOS", "FACEBOOK", "WHATSAPP", "EMAILS", "ACESSO TOTAL"}
    
    -- Header do ataque
    tela.setTextColor(colors.red)
    tela.setCursorPos(10, 2)
    tela.write("EXECUTANDO ATAQUE: " .. modoNomes[modoSelecionado])
    tela.setCursorPos(10, 3)
    tela.write("ALVO: " .. alvoSelecionado .. " (" .. info.ip .. ")")
    
    -- Fase 1: Exploração
    tela.setCursorPos(5, 5)
    tela.setTextColor(colors.cyan)
    efeitoDigitacao("[FASE 1] Explorando vulnerabilidades...\n", 0.05, colors.cyan)
    
    for _, vuln in ipairs(info.vulnerabilidades) do
        tela.setCursorPos(7, 6)
        tela.setTextColor(colors.white)
        efeitoDigitacao("• Explorando " .. vuln .. "...", 0.03, colors.white)
        sleep(0.5)
        tela.setCursorPos(40, 6)
        tela.setTextColor(colors.lime)
        tela.write("✓")
        tela.setCursorPos(7, 6)
        tela.write("                                   ")
    end
    
    -- Fase 2: Acesso
    tela.setCursorPos(5, 8)
    tela.setTextColor(colors.cyan)
    efeitoDigitacao("[FASE 2] Obtendo acesso...\n", 0.05, colors.cyan)
    
    local passosAcesso = {
        "Bypassando autenticação...",
        "Estabelecendo conexão reversa...",
        "Elevando privilégios...",
        "Acessando sistema..."
    }
    
    for i, passo in ipairs(passosAcesso) do
        tela.setCursorPos(7, 9 + i)
        tela.setTextColor(colors.white)
        efeitoDigitacao(passo, 0.03, colors.white)
        sleep(0.8)
        tela.setCursorPos(40, 9 + i)
        tela.setTextColor(colors.lime)
        tela.write("✓")
    end
    
    -- Fase 3: Extração de dados
    tela.setCursorPos(5, 14)
    tela.setTextColor(colors.cyan)
    efeitoDigitacao("[FASE 3] Extraindo dados...\n", 0.05, colors.cyan)
    
    local dadosExtraidos = {}
    
    if modoSelecionado == 1 then -- Banco
        dadosExtraidos = {
            "Banco: " .. info.dados.banco,
            "Agência: " .. math.random(1000, 9999),
            "Conta: " .. math.random(10000, 99999),
            "Saldo: R$ " .. math.random(1000, 50000) .. ",00",
            "Cartão: **** **** **** " .. math.random(1000, 9999)
        }
    elseif modoSelecionado == 2 then -- Facebook
        dadosExtraidos = {
            "Usuário: " .. info.dados.facebook,
            "Senha: ********",
            "Email: " .. info.dados.email,
            "Amigos: " .. math.random(100, 500),
            "Último login: " .. os.date("%d/%m/%Y %H:%M")
        }
    elseif modoSelecionado == 3 then -- WhatsApp
        dadosExtraidos = {
            "Número: " .. info.dados.whatsapp,
            "Status: Online",
            "Última visto: " .. os.date("%H:%M"),
            "Contatos: " .. math.random(50, 200),
            "Backup extraído: " .. math.random(1, 50) .. "MB"
        }
    elseif modoSelecionado == 4 then -- Emails
        dadosExtraidos = {
            "Email principal: " .. info.dados.email,
            "Emails encontrados: " .. math.random(10, 50),
            "Caixa de entrada: " .. math.random(1, 100),
            "Emails sensíveis: " .. math.random(1, 10),
            "Contas vinculadas: " .. math.random(2, 8)
        }
    elseif modoSelecionado == 5 then -- Acesso total
        dadosExtraidos = {
            "Acesso root concedido",
            "IP: " .. info.ip,
            "Sistema: " .. info.sistema,
            "Usuário: Administrator",
            "Senha: ************"
        }
    end
    
    for i, dado in ipairs(dadosExtraidos) do
        tela.setCursorPos(7, 15 + i)
        tela.setTextColor(colors.yellow)
        efeitoDigitacao("• " .. dado, 0.03, colors.yellow)
        sleep(0.5)
    end
    
    -- Barra de progresso final
    tela.setCursorPos(5, 22)
    tela.setTextColor(colors.cyan)
    tela.write("PROGRESSO: [")
    
    for i = 1, 30 do
        tela.setCursorPos(16 + i, 22)
        if i <= 10 then
            tela.setTextColor(colors.red)
        elseif i <= 20 then
            tela.setTextColor(colors.yellow)
        else
            tela.setTextColor(colors.green)
        end
        tela.write("█")
        sleep(0.05)
    end
    
    tela.setTextColor(colors.cyan)
    tela.write("] 100%")
    
    -- Resultado
    tela.setCursorPos(10, 24)
    tela.setTextColor(colors.lime)
    tela.write("✓ ATAQUE CONCLUÍDO COM SUCESSO!")
    
    -- Salvar dados em "arquivo"
    tela.setCursorPos(5, 26)
    tela.setTextColor(colors.white)
    tela.write("Dados salvos em: /hacks/" .. alvoSelecionado .. "_" .. os.time() .. ".txt")
    
    sleep(4)
    modoSelecionado = nil
end

-- Loop principal
local estado = "selecao_alvo"  -- selecao_alvo, selecao_modo, atacando

while true do
    if estado == "selecao_alvo" then
        telaSelecaoAlvo()
    elseif estado == "selecao_modo" then
        telaModosAtaque()
    end
    
    local evento = {os.pullEvent()}
    
    if evento[1] == "key" then
        local tecla = evento[2]
        
        if estado == "selecao_alvo" then
            local alvoNomes = {}
            local i = 1
            for nome, _ in pairs(alvos) do
                alvoNomes[i] = nome
                i = i + 1
            end
            
            if tecla == keys.up then
                if not alvoSelecionado then
                    alvoSelecionado = alvoNomes[1]
                else
                    for i, nome in ipairs(alvoNomes) do
                        if nome == alvoSelecionado then
                            alvoSelecionado = alvoNomes[i-1] or alvoNomes[#alvoNomes]
                            break
                        end
                    end
                end
            elseif tecla == keys.down then
                if not alvoSelecionado then
                    alvoSelecionado = alvoNomes[1]
                else
                    for i, nome in ipairs(alvoNomes) do
                        if nome == alvoSelecionado then
                            alvoSelecionado = alvoNomes[i+1] or alvoNomes[1]
                            break
                        end
                    end
                end
            elseif tecla == keys.enter then
                if alvoSelecionado then
                    modoSelecionado = 1
                    estado = "selecao_modo"
                end
            elseif tecla == keys.q then
                break
            end
            
        elseif estado == "selecao_modo" then
            if tecla == keys.up then
                modoSelecionado = (modoSelecionado - 2) % 6 + 1
            elseif tecla == keys.down then
                modoSelecionado = modoSelecionado % 6 + 1
            elseif tecla == keys.enter then
                if modoSelecionado == 6 then
                    estado = "selecao_alvo"
                else
                    executarAtaque()
                    estado = "selecao_alvo"
                    alvoSelecionado = nil
                end
            elseif tecla == keys.backspace then
                estado = "selecao_alvo"
            end
        end
    end
    
    sleep(0.05)
end

-- Encerramento
tela.clear()
tela.setCursorPos(10, 10)
tela.setTextColor(colors.red)
tela.write("DESCONECTANDO DO SISTEMA...")
sleep(2)
tela.clear()
tela.setCursorPos(1, 1)
print("Sistema de hack encerrado.")
