import Foundation

//==item: (nome, tipo, valor)  tipo: "cura","stamina","armadura","arma">>
let itens: [(String, String, Int)] = [
    ("Cura +50","cura",50), ("Cura +100","cura",100), ("Bandagem","cura",30),
    ("Água","stamina",20), ("Peitoral de Ferro","armadura",40), ("Peitoral de Couro","armadura",20),
    ("Faca","arma",0), ("Swift","arma",0), ("Java","arma",0), ("Chave Inglesa","arma",0), ("Rifle","arma",0)
]

//==locais>>
let locais = ["Casa","Carro","Loja","Armazém","Garagem","Oficina"]

//==temporizador>>
func agoraEmSegundos() -> Int {
    return Int(Date().timeIntervalSince1970)
}

func pausar(_ mensagem: String = "Pressione RETURN para continuar...") {
    print(mensagem)
    _ = readLine()
}

//==player>>
typealias Player = (nome: String, classe: String, vida: Int, stamina: Int, arma: String, danoMin: Int, danoMax: Int, defesa: Int, inventario: [String])


func criarPlayer() -> Player {
    print("Escolha sua classe:")
    print("1 - Policial (Pistola)")
    print("2 - Enfermeiro (Kit Médico)")
    print("3 - Atleta (mais chance de fuga)")
    print("4 - Swifteiro (Swift)")
    let op = readLine() ?? "1"
    switch op {
    case "1":
        return ("Você","Policial",200,100,"Pistola",70,200,0,[])
    case "2":
        return ("Você","Enfermeiro",200,100,"Punhos",30,50,0,["Kit Médico"])
    case "3":
        return ("Você","Atleta",200,100,"Punhos",30,50,0,[])
    case "4":
        return ("Você","Swifteiro",200,100,"Swift",90,250,0,[])
    default:
        return ("Você","Javeiro",200,100,"Java",80,200,0,[])
    }
}

func equiparArma(_ p: Player, nome: String) -> Player {
    var novo = p
    novo.arma = nome
    switch nome {
    case "Faca": novo.danoMin = 40; novo.danoMax = 60
    case "Swift": novo.danoMin = 90; novo.danoMax = 250
    case "Java": novo.danoMin = 80; novo.danoMax = 200
    case "Chave Inglesa": novo.danoMin = 50; novo.danoMax = 80
    case "Rifle": novo.danoMin = 100; novo.danoMax = 500
    case "Pistola": novo.danoMin = 70; novo.danoMax = 200
    default: novo.danoMin = 30; novo.danoMax = 50
    }
    print("Equipado: \(novo.arma) (\(novo.danoMin)-\(novo.danoMax) dano)")
    return novo
}

func usarItemNoPlayer(_ p: Player, itemNome: String) -> Player {
    var novo = p
    var inv = novo.inventario
    if let idx = inv.firstIndex(of: itemNome) {
        inv.remove(at: idx)
        novo.inventario = inv
        
        if itemNome.contains("Cura") || itemNome == "Bandagem" || itemNome == "Kit Médico" {
            if itemNome.contains("100") { novo.vida = min(200, novo.vida + 100) }
            else if itemNome.contains("50") { novo.vida = min(200, novo.vida + 50) }
            else if itemNome == "Bandagem" { novo.vida = min(200, novo.vida + 30) }
            else if itemNome == "Kit Médico" { novo.vida = min(200, novo.vida + 100) }
            print("Usou \(itemNome). Vida: \(novo.vida)")
        } else if itemNome == "Água" {
            novo.stamina = min(100, novo.stamina + 20)
            print("Usou Água. Stamina: \(novo.stamina)")
        } else if itemNome.contains("Peitoral") {
            if itemNome.contains("Ferro") { novo.defesa += 40 }
            else { novo.defesa += 20 }
            print("Equipou \(itemNome). Defesa: \(novo.defesa)")
        }
    } else {
        print("Item não encontrado no inventário.")
    }
    return novo
}

func mostrarInventario(_ p: Player) {
    print("Inventário (apenas cura/stamina/armadura):")
    if p.inventario.isEmpty {
        print("- vazio")
    } else {
        for it in p.inventario { print("- \(it)") }
    }
    pausar()
}


//==evento>>
func encontrarItemAoVasculhar(_ p: Player) -> (Player, Bool) {
    var player = p
    let roll = Int.random(in: 1...100)
    if roll <= 40 {
        let item = itens.randomElement()!
        print("Você encontrou: \(item.0) [\(item.1)]")
        
        if item.1 == "arma" {
            print("Deseja trocar sua arma atual (\(player.arma)) por \(item.0)?")
            print("s - Sim")
            print("n - Não")
            let s = (readLine() ?? "n").lowercased()
            if s == "s" || s == "sim" {
                player = equiparArma(player, nome: item.0)
            } else {
                print("Você deixou a arma.")
            }
        } else if item.1 == "armadura" {
            player.defesa += item.2
            print("Você equipou \(item.0). Defesa: \(player.defesa)")
        } else {
            player.inventario.append(item.0)
            print("\(item.0) guardado no inventário.")
        }
        
        pausar()
        return (player, false)
    } else {
        print("Nada Encontrado!")
        pausar()
        return (player, true)
    }
}

func eventoLocal(_ local: String, p: Player) -> (Player, Bool) {
    let player = p
    print("Você chegou em uma \(local). Deseja vasculhar?")
    print("s - Sim")
    print("n - Não")
    let resp = (readLine() ?? "n").lowercased()
    
    if resp == "s" || resp == "sim" {
        print("Vasculhando a \(local)...")
        pausar()
        return encontrarItemAoVasculhar(player)
    } else {
        print("Você decidiu não vasculhar.")
        pausar()
        return (player, false)
    }
}

func eventoAleatorio(_ p: Player) -> Player {
    var player = p
    let roll = Int.random(in: 1...100)
    
    if roll <= 30 {
        let local = locais.randomElement()!
        let res = eventoLocal(local, p: player)
        player = res.0
        if res.1 {
            player = combate(player, quantidade: Int.random(in: 1...3))
        }
    } else {
        let grupo = Int.random(in: 1...100) <= 70 ? 1 : Int.random(in: 2...3)
        player = combate(player, quantidade: grupo)
    }
    
    return player
}

//==combate>>
func causarDanoAoPlayer(_ p: Player, base: Int) -> Player {
    var player = p
    let danoFinal = max(5, base - player.defesa)
    player.vida -= danoFinal
    print("Você recebeu \(danoFinal) de dano. Vida: \(player.vida)")
    return player
}

func atacarZumbi(_ player: Player, vidaZumbi: Int) -> (Player, Int) {
    let pl = player
    var zVida = vidaZumbi
    
    var headChance = 20
    if pl.arma == "Pistola" { headChance = 50 }
    else if pl.arma == "Rifle" { headChance = 75 }
    
    let tiro = Int.random(in: 1...100)
    if tiro <= headChance {
        print("HEADSHOT! Zumbi eliminado.")
        return (pl, 0)
    }
    
    let dano = Int.random(in: pl.danoMin...pl.danoMax)
    zVida -= dano
    print("Você causou \(dano) de dano. Vida do zumbi: \(max(0,zVida))")
    return (pl, zVida)
}

//==fuga>>
func tentarFuga(_ p: Player) -> (Player, Bool) {
    var player = p
    var chance = 50
    
    if player.classe == "Atleta" { chance += 80 }
    if player.stamina < 20 {
        print("Stamina baixa! Fugir é mais arriscado.")
        chance -= 25
    }
    
    player.stamina = max(0, player.stamina - 20)
    let sucesso = Int.random(in: 1...100) <= chance
    if sucesso { print("Fuga bem sucedida!") }
    else { print("Fuga falhou!") }
    
    return (player, sucesso)
}

//==inventario>>
func usarItemMenu(_ p: Player) -> Player {
    let player = p
    var usaveis: [String] = []
    
    for it in player.inventario {
        if it.contains("Cura") || it == "Bandagem" || it == "Kit Médico" || it == "Água" || it.contains("Peitoral") {
            usaveis.append(it)
        }
    }
    
    if usaveis.isEmpty {
        print("Sem itens usáveis.")
        pausar()
        return player
    }
    
    print("Escolha um item para usar:")
    for i in 0..<usaveis.count { print("\(i+1) - \(usaveis[i])") }
    
    let escolha = Int(readLine() ?? "1") ?? 1
    if escolha < 1 || escolha > usaveis.count {
        print("Escolha inválida.")
        pausar()
        return player
    }
    
    return usarItemNoPlayer(player, itemNome: usaveis[escolha-1])
}

//==combate>>
func combate(_ p: Player, quantidade: Int) -> Player {
    var player = p
    print("Iniciando combate contra \(quantidade) zumbi(s).")
    pausar("Pressione ENTER para começar...")
    
    for idx in 1...quantidade {
        var zVida = Int.random(in: 100...300)
        print("\n--- Inimigo \(idx) (Vida: \(zVida)) ---")
        
        while zVida > 0 && player.vida > 0 {
            print("\nVocê - Vida:\(player.vida) Stamina:\(player.stamina) Defesa:\(player.defesa)")
            print("Ações: 1-Atacar  2-Correr  3-Usar Item  4-Inventário")
            
            let ac = readLine() ?? "1"
            
            if ac == "1" {
                pausar("Pressione ENTER para atacar...")
                let res = atacarZumbi(player, vidaZumbi: zVida)
                player = res.0; zVida = res.1
                
            } else if ac == "2" {
                pausar("Pressione ENTER para tentar correr...")
                let fug = tentarFuga(player)
                player = fug.0
                
                if fug.1 {
                    print("Você escapou do combate.")
                    return player
                } else {
                    player = causarDanoAoPlayer(player, base: Int.random(in: 50...70))
                }
                
            } else if ac == "3" {
                player = usarItemMenu(player)
                
            } else if ac == "4" {
                mostrarInventario(player)
                
            } else {
                print("Entrada inválida.")
            }
            
            if zVida > 0 {
                player = causarDanoAoPlayer(player, base: Int.random(in: 20...40))
            }
        }
        
        if player.vida <= 0 { break }
        
        print("Zumbi \(idx) derrotado!")
        if Int.random(in: 1...100) <= 30 {
            player.inventario.append("Bandagem")
            print("Drop: Bandagem adicionada ao inventário.")
        }
        pausar()
    }
    
//==menuDcombate>>
    while true {
        print("\nO que deseja fazer?")
        print("1 - Usar item")
        print("2 - Continuar caminhando")

        let opt = readLine() ?? "2"

        if opt == "1" {
            player = usarItemMenu(player)
        } else if opt == "2" {
            break
        } else {
            print("Opção inválida.")
        }
    }

    return player
}


//==Iniciar>>
let inicio = agoraEmSegundos()
var jogador = criarPlayer()
print("Bem-vindo \(jogador.classe)")
print("Seu objetivo é simples: Sobreviva o máximo que conseguir.")
pausar()

while jogador.vida > 0 {
   print("\nCaminhar: pressione RETURN para iniciar contagem")
_ = readLine()

for i in (1...3).reversed() {
    print("Caminhando... \(i)")
    Thread.sleep(forTimeInterval: 0.3)
}

    
    jogador = eventoAleatorio(jogador)
}

let fim = agoraEmSegundos()
print("\n💀 Você morreu!")
print("⏱ Tempo de sobrevivência: \(fim - inicio) segundos")

