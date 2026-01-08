-- hack_simples.lua
local tela = peripheral.find("monitor") or term
tela.clear()
tela.setBackgroundColor(colors.black)

print("Iniciando simulação de hack...")

-- Funções de efeito
local function escreverVerde(texto)
    tela.setTextColor(colors.green)
    tela.write(texto)
end

local function escreverVermelho(texto)
    tela.setTextColor(colors.red)
    tela.write(texto)
end

local function escreverCiano(texto)
    tela.setTextColor(colors.cyan)
    tela.write(texto)
end

-- Animação inicial
tela.setCursorPos(1, 1)
escreverCiano("=== SISTEMA DE PENETRAÇÃO ===")
tela.setCursorPos(1, 2)
escreverVerde("Inicializando...")

for i = 1, 3 do
    tela.setCursorPos(12, 2)
    escreverVerde(string.rep(".", i))
    sleep(0.5)
end

tela.clear()

-- Tela principal
local comandos = {
    "scan --target 192.168.1.1",
    "exploit --vulnerability CVE-2023-1234",
    "bruteforce --service ssh --wordlist rockyou.txt",
    "sqlmap --url http://alvo.com/login",
    "metasploit --payload windows/meterpreter",
    "wireshark --capture eth0",
    "nmap -sS -sV -O alvo.com",
    "john --wordlist=passwords.txt hash.txt",
    "hydra -l admin -P pass.txt ssh://192.168.1.1",
    "aircrack-ng capture.cap -w wordlist.txt"
}

local linha = 5
local velocidade = 0.1

while true do
    -- Cabeçalho
    tela.setCursorPos(1, 1)
    escreverVermelho("root@hacker:~# ")
    escreverVerde("sudo hack --aggressive")
    
    tela.setCursorPos(1, 3)
    escreverCiano("---------------------------------------------------")
    
    -- Mostrar comandos "executando"
    if linha > 20 then
        tela.clear()
        linha = 5
    end
    
    local comando = comandos[math.random(#comandos)]
    tela.setCursorPos(3, linha)
    escreverVerde("$ " .. comando)
    
    linha = linha + 1
    
    -- Mostrar saída do comando
    tela.setCursorPos(5, linha)
    
    local saidas = {
        "[+] Vulnerabilidade encontrada!",
        "[!] Bypassando autenticação...",
        "[✓] Acesso root obtido",
        "[*] Transferindo dados...",
        "[#] Limpando logs...",
        "[>] Estabelecendo conexão reversa",
        "[~] Criptografando canal..."
    }
    
    escreverCiano(saidas[math.random(#saidas)])
    
    linha = linha + 2
    
    -- Barra de progresso aleatória
    if math.random(1, 3) == 1 then
        tela.setCursorPos(3, linha)
        escreverVerde("Progresso: [")
        
        local progresso = math.random(20, 100)
        local barras = math.floor(progresso / 5)
        
        tela.setTextColor(colors.green)
        tela.write(string.rep("█", barras))
        tela.setTextColor(colors.gray)
        tela.write(string.rep("░", 20 - barras))
        escreverVerde("] " .. progresso .. "%")
        
        linha = linha + 1
    end
    
    -- IP aleatório
    tela.setCursorPos(1, 23)
    escreverCiano("IP: 192.168." .. math.random(1, 255) .. "." .. math.random(1, 255))
    tela.setCursorPos(30, 23)
    escreverVerde("STATUS: ATIVO")
    
    -- Instruções
    tela.setCursorPos(1, 25)
    tela.setTextColor(colors.white)
    tela.write("Pressione Ctrl+T para sair")
    
    sleep(velocidade)
    
    -- Aumentar velocidade gradualmente
    if velocidade > 0.02 then
        velocidade = velocidade * 0.98
    end
end
