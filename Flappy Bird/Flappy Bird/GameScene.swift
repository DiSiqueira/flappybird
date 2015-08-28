//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Diego Siqueira on 8/27/15.
//  Copyright (c) 2015 Diego Siqueira. All rights reserved.
//

import SpriteKit

//Sprite Node que representará o nosso pássaro
var passaro:    SKSpriteNode = SKSpriteNode()
//Sprite Node uma tela cinza para cobrir o ecrã quando o jogo termina
var cobrir:     SKSpriteNode = SKSpriteNode()
//Duas imagens de fundo iremos necessitar de duas irei explicar o porque
var Fundo1:     SKSpriteNode = SKSpriteNode()
var Fundo2:     SKSpriteNode = SKSpriteNode()
//Tambem duas imagens para o chão
var Chao1:      SKSpriteNode = SKSpriteNode()
var Chao2:      SKSpriteNode = SKSpriteNode()
//A textura para o passaro com a imagem "bird.png"
var TexturaPassaro = SKTexture(imageNamed: "bird" )
//Label para exibir a pontuação
var pontuacaoL: SKLabelNode = SKLabelNode(fontNamed: "System-bold")
//Uma nova class Pipe para os tubos já veremos como é criada
var TuboBase:   Pipe  = Pipe()
//O espaço entre o tubo de cima e o de baixo
var Espaco:     Float = 250
//Variáveis que nos permitem colocar os tubos mais a cima ou mais a baixo aleatoriamente
var prevNum:    Float = 0
var maxRange:   Float = 175
var minRange:   Float = -100
//Velocidade a que o jogo se desenrola
var Velocidade: Float = 3.0
//Inteiro para a pontuação
var Pontuacao:  Int   = 0
//Bool para controlarmos se o jogo já se iniciou ou ainda não
var emMovimento:Bool  = false
//Variáveis para colisão
var birdCategory: UInt32 = 1
var pipeCategory: UInt32 = 2
//Array para guardar os tubos que existem no jogo
var Tubos:      [Pipe] = []


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    override func didMoveToView(view: SKView)
    {
        //Definir o tubo padrão com cor preta, largura igual a largura da
        //tela a dividir por 6, e altura de 480
        TuboBase = Pipe(color: UIColor.blackColor(), size: CGSize(width: (view.bounds.size.width) / 6, height: 480))
        
        //O Cobrir fica do tamanho da nossa tela, cor cinzenta meio transparente "alpha = 0.7"
        cobrir = SKSpriteNode(color: UIColor.grayColor(), size:CGSize(width:view.bounds.size.width, height:view.bounds.size.height))
        cobrir.alpha = 0.7
        // a posição Z é de 11 para que quando ela aparecer se sobreponha a tudo
        cobrir.zPosition = 11
        cobrir.position.x = view.bounds.size.width / 2
        cobrir.position.y = view.bounds.size.height / 2
        
        //A Label pontuação é colocada no canto superior esquerdo, mas para já fica escondida
        pontuacaoL.position.x = 13
        pontuacaoL.position.y = view.bounds.size.height - 50
        pontuacaoL.text = "Pontos: 0"
        pontuacaoL.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        pontuacaoL.hidden = true
        
        //No objecto Chão vamos colocar a imagem "Ground.png"
        Chao1 = SKSpriteNode(imageNamed: "Ground")
        Chao1.size.width = view.bounds.width + 2
        Chao1.position.x = view.bounds.width * 0.5
        Chao1.position.y = Chao1.size.height * 0.4
        Chao1.texture?.filteringMode = SKTextureFilteringMode.Nearest
        //O seu corpo fisico será do mesmo tamanho da imagem que iremos visualizar
        Chao1.physicsBody = SKPhysicsBody(rectangleOfSize: Chao1.size)
        //dynamic = false para que não reaja a colisões ou forças de gravidade
        Chao1.physicsBody?.dynamic = false
        Chao1.zPosition = 10
        
        //As duas variáveis Chao são quase iguais só diferencia a sua posição, enquanto
        // a primeira fica no centro do ecrã esta fica á direita do ecrã, com isto iremos
        // criar uma noção de movimento em que o cenário parece não acabar :)
        Chao2 = SKSpriteNode(imageNamed: "Ground")
        Chao2.size.width = view.bounds.width + 2
        Chao2.position.x = view.bounds.width * 1.5
        Chao2.position.y = Chao2.size.height * 0.4
        Chao2.texture?.filteringMode = SKTextureFilteringMode.Nearest
        Chao2.physicsBody = SKPhysicsBody(rectangleOfSize: Chao2.size)
        Chao2.physicsBody?.dynamic = false
        Chao2.zPosition = 10
        
        //Os fundos seguem a mesma lógica do chão, para estes
        // vamos colocar a imagem "Background.png"
        Fundo1 = SKSpriteNode(imageNamed: "Background")
        Fundo1.position.x = view.bounds.width * 0.5
        Fundo1.position.y = view.bounds.height * 0.5
        Fundo1.texture?.filteringMode = SKTextureFilteringMode.Nearest
        
        //Mesma logica do Chao2
        Fundo2 = SKSpriteNode(imageNamed: "Background")
        Fundo2.position.x = view.bounds.width * 1.5
        Fundo2.position.y = view.bounds.height * 0.5
        Fundo2.texture?.filteringMode = SKTextureFilteringMode.Nearest
        
        //Este filteringMode serve para ajustarmos o tamanho da imagem do passaro
        // ao seu objecto
        TexturaPassaro.filteringMode = SKTextureFilteringMode.Nearest
        passaro = SKSpriteNode(texture: TexturaPassaro)
        passaro.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        //Para já e como o jogo ainda não começou vamos colocar o pássaro estatico
        passaro.physicsBody?.dynamic = false
        passaro.physicsBody?.contactTestBitMask = pipeCategory
        passaro.physicsBody?.collisionBitMask = pipeCategory
        passaro.zPosition = 9
        passaro.position = CGPoint(x: 150, y: view.bounds.width / 2 - 10)
        
        //Aqui colocamos a física do nosso mundo onde a gravidade vai ser y = -0.5
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -5.0)
        
        //Adicionar ao ecrã os objectos criados anteriormente menos o Cobrir
        // que apenas será colocado no fim do jogo
        self.addChild(Fundo1)
        self.addChild(Fundo2)
        self.addChild(Chao1)
        self.addChild(Chao2)
        self.addChild(pontuacaoL)
        self.addChild(passaro)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        //Se o Passaro tem physicsBody.dynamic = false então é o primeiro toque,
        // e o vai iniciar-se
        if(!passaro.physicsBody.dynamic)
        {
            //Chamar spawnPipeRow para crias os primeiros dois tubos
            self.spawnPipeRow(0)
            //Tornar o pássaro influenciável pelo ambiente
            passaro.physicsBody.dynamic = true
            //Colocamos uma velocidade de 175 na vertical que fará,
            // o pássaro dar o primeiro salto
            passaro.physicsBody.velocity = CGVectorMake(0, 175)
            //Deixamos de esconder a label da pontuação
            pontuacaoL.hidden = false
            //Identificamos que o movimento do pássaro de iniciou
            emMovimento = true
        }
        else if(emMovimento)
        {
            //Velocidade de salto por defeito de 200
            var vel: Float = 200
            //Se o pássaro se encontrar perto do cimo reduzir a velocidade do salto
            if(self.view.bounds.size.height - passaro.position.y &amp;amp;amp;amp;amp;lt; 85)
            {
                vel -= 85 - (self.view.bounds.size.height - position.y )
            }
            passaro.physicsBody.velocity = CGVectorMake(0, vel)
        }
            
            //Se o jogo se encontrar parado por Game Over recomeçar de novo
        else
        {
            //Remover aTela que cobre o ecrã
            cobrir.removeFromParent()
            //Apagar todos os tubos no array da tela
            for pi in Tubos
            {
                pi.removeFromParent()
            }
            //E remover também do array
            Tubos.removeAll(keepCapacity: false)
            //Colocar pontuação a Zero
            Pontuacao = 0
            //E colocar Passaro com posição e definições de inicio de jogo
            passaro.physicsBody.dynamic = false
            passaro.position = CGPoint(x: 150, y: view.bounds.width / 2 - 10)
            pontuacaoL.hidden = true
            emMovimento = false
        }
        
    }
   
    override func update(currentTime: CFTimeInterval)
    {
        //Se jogo a decorrer
        if(emMovimento)
        {
            //Mover o fundo ligeiramente para a esquerda: o valor da velocidade/2
            //A velocidade é dividida por 2 para nos dar um efeito paralaxe no movimento
            Fundo1.position.x -= Velocidade / 2
            Fundo2.position.x -= Velocidade / 2
            
            //Aqui vamos controlar cada vez que um dos fundos sai da tela pela sua esquerda,
            // vamos move-la instantaneamente para a direita da tela, para que esta comece
            // a entrar pela direita. Parece confuso mas não é.
            if(Fundo1.position.x &amp;amp;amp;amp;amp;lt;= -view.bounds.width / 2)
            {
                Fundo1.position.x = view.bounds.width * 1.5 - 2
            }
            if(Fundo2.position.x &amp;amp;amp;amp;amp;lt;= -view.bounds.width / 2)
            {
                Fundo2.position.x = view.bounds.width * 1.5 - 2
            }
            
            //O código seguinte segue a mesma lógica do fundo mas para o chão
            Chao1.position.x -= Velocidade
            Chao2.position.x -= Velocidade
            if(Chao1.position.x &amp;amp;amp;amp;amp;lt;= -view.bounds.width / 2)
            {
                Chao1.position.x = view.bounds.width * 1.5 - 2
            }
            if(Chao2.position.x &amp;amp;amp;amp;amp;lt;= -view.bounds.width / 2)
            {
                Chao2.position.x = view.bounds.width * 1.5 - 2
            }
            
            //A cada um dos tubos criados
            for(var i = 0; i &amp;amp;amp;amp;amp;lt; Tubos.count; i++)
            {
                let pipe = Tubos[i]
                
                //Se um tubo de baixo já passou pelo pássaro então somamos um ponto e
                // marcamos o tubo para que não pontue mais
                if(pipe.position.x + pipe.size.width / 2 &amp;amp;amp;amp;amp;lt;
                    passaro.position.x &amp;amp;amp;amp;amp;amp;&amp;amp;amp;amp;amp;amp; pipe.isBottom &amp;amp;amp;amp;amp;amp;&amp;amp;amp;amp;amp;amp; !pipe.jaPontuo)
                {
                    Pontuacao++
                    pipe.jaPontuo = true
                }
                
                //Mover o tubo para a esquerda com a velocidade definida
                pipe.position.x -= Velocidade
                //Se temos tubos a menos e já está na altura de criar novos tubos então
                if(i == Tubos.count - 1)
                {
                    if(pipe.position.x &amp;amp;amp;amp;amp;lt; self.view.bounds.width - pipe.size.width * 2.0)
                    {
                        //Criamos novos tubos com um Offset aleatório
                        self.spawnPipeRow(self.randomOffset())
                    }
                }
            }
            
            //Atualizamos a label pontuação
            pontuacaoL.text = "Pontos: \(Pontuacao)"
            
            for(var i = 0; i &amp;amp;amp;amp;amp;lt; Tubos.count; i++)
            {
                let pipe = Tubos[i]
                
                //Se tubo ja saiu da tela será apagado
                if (pipe.position.x + (pipe.size.width / 2) &amp;amp;amp;amp;amp;lt; 0)
                {
                    Tubos.removeAtIndex(i)
                    pipe.removeFromParent()
                    continue
                }
            }
            
        }
    }
    
    //Na spawnPipeRow temos um parâmetro de entrada offs que representa
    //quanto os tubos vão subir ou descer.
    func spawnPipeRow(offs: Float)
    {
        //Com base no offs e no Espaco podemos determinar o deslocamento exato do tubo.
        let offset     = offs - Espaco / 2
        //Declaração dos dois tubos
        let pipeBottom = TuboBase.copy() as Pipe
        let pipeTop    = TuboBase.copy() as Pipe
        //A posição x onde termina a tela
        let xx         = Float(self.view.bounds.size.width)
        
        //Aqui definimos para o tubo de baixo a imagem, se é um tubo de cima ou de baixo
        // e sua posição baseada no offset e no xx
        pipeBottom.texture = SKTexture(imageNamed: "BotPipe")
        pipeBottom.texture.filteringMode = SKTextureFilteringMode.Nearest
        pipeBottom.isBottom = true
        //A função SetRelativePositionBot será explicada mais a frente para já basta sabermos
        // que tem o objectivo de colocar o nosso tubo no sitio certo
        self.SetRelativePositionBot(pipeBottom, x: xx, y: offset)
        //Definição das dimensões do seu corpo físico
        pipeBottom.physicsBody = SKPhysicsBody(rectangleOfSize: pipeBottom.size)
        pipeBottom.physicsBody.dynamic = false
        pipeBottom.physicsBody.contactTestBitMask = birdCategory
        pipeBottom.physicsBody.collisionBitMask = birdCategory
        //Adicionamos o tubo ao nosso array
        Tubos.append(pipeBottom)
        //E por fim adicionamos ao cenário
        self.addChild(pipeBottom)
        
        //Neste pedaço de código vamos repetir o mesmo a cima mas
        // para o tubo de cima.
        pipeTop.texture = SKTexture(imageNamed: "TopPipe")
        pipeTop.texture.filteringMode = SKTextureFilteringMode.Nearest
        //Temos aqui uma variante no Y pois vamos adicionar ao offset o Espaco
        // assim ao seu deslocamento adicionamos mais o valor do espaço que
        // provocará o intervalo entre os 2 tubos
        self.SetRelativePositionTop(pipeTop, x: xx, y: offset + Espaco)
        pipeTop.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTop.size)
        pipeTop.physicsBody.dynamic = false
        pipeTop.physicsBody.contactTestBitMask = birdCategory
        pipeTop.physicsBody.collisionBitMask = birdCategory
        Tubos.append(pipeTop)
        self.addChild(pipeTop)
    }
    
    //Temos como parâmetros de entrada o tubo alvo, a posição x e y
    func SetRelativePositionBot(node: SKSpriteNode, x:Float, y:Float)
    {
        //O x é fácil é o nosso parâmetro X mais metade da largura do nosso tubo,
        // temos de acrescentar metade da largura porque o tubo será criado a partir
        // do seu centro, logo teremos de dar um desconto.
        let xx = (Float(node.size.width) / 2) + x
        //No y temos o centro da altura da tela mais o parâmetro Y mais metade
        // da altura como explicado anteriormente
        let yy = Float(self.view.bounds.size.height) / 2 -  (Float(node.size.height) / 2 ) + y
        
        node.position.x = CGFloat(xx)
        node.position.y = CGFloat(yy)
    }
    
    //Função SetRelativePositionTop igual a anterior mas para o tubo de cima
    func SetRelativePositionTop (node: SKSpriteNode, x:Float, y:Float)
    {
        let xx = (Float(node.size.width) / 2) + x
        let yy = Float(self.view.bounds.size.height) / 2 +  (Float(node.size.height) / 2 ) + y
        node.position.x = CGFloat(xx)
        node.position.y = CGFloat(yy)
    }
    
    func didBeginContact(contact: SKPhysicsContact!)
    {
        //Se aconteceu algum contacto então
        if(emMovimento)
        {
            //Paramos o movimento
            emMovimento = false
            //Paramos o pássaro
            passaro.physicsBody.velocity = CGVectorMake(0, 0 )
            //Eliminamos os tubos
            for pi in Tubos
            {
                pi.physicsBody = nil
            }
            //E por fim cobrir o ecrã com a tela cinzenta
            self.addChild(cobrir)
        }
        else
        {
            passaro.physicsBody.velocity = CGVectorMake(0, 0 )
        }
    }
    
    func randomOffset() -> Float
    {
        let max = maxRange - prevNum
        let min = minRange - prevNum
        var rNum:  Float = Float(arc4random() % 61) + 40
        var rNum1: Float = Float(arc4random() % 31) + 1
        if(rNum1 % 2 == 0)
        {   var tempNum = prevNum + rNum
            if(tempNum &amp;amp;amp;amp;amp;gt; maxRange)
            {  tempNum = maxRange - rNum }
            rNum = tempNum
        }else
        {  var tempNum = prevNum - rNum
            if(tempNum &amp;amp;amp;amp;amp;lt; minRange)
            {   tempNum = minRange + rNum }
            rNum = tempNum
        }
        prevNum = rNum
        return rNum
    }
}



class Pipe: SKSpriteNode
{
    var isBottom: Bool = false
    var jaPontuo: Bool = false
    
}
