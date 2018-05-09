CPqDASR SDK para iOS
===================
O CPqDASR é uma framework para a criação de aplicações de voz que utilizam o servidor CPqD ASR para reconhecimento de fala.

Para maiores informações, consulte [a documentação do projeto](https://speechweb.cpqd.com.br/asr/docs).

## Aplicação de exemplo

A aplicação de demonstração está no diretório [CPqDASRDemo](CPqDASRDemo/).

## Uso

### Criar uma instância de *CPqDASRSpeechRecognizer*:

Uma instância de *CPqDASRSpeechRecognizer* é obtida utilizando um [Builder](https://en.wikipedia.org/wiki/Builder_pattern).

Crie uma instância de `CPqDASRSpeechRecognizerBuilder` passando os parâmetros necessários para o reconhecimento de fala. A seguir está um exemplo de criação do *Builder* utilizando somente os parâmetros obrigatórios.

**Swift**:
```swift
let builder = CPqDASRSpeechRecognizerBuilder()
            .serverUrl(wsURL)
            .addRecognitionDelegate(self)
            .userName(username, password: password)
```
**Objective-C**:
```objc

CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] init]
                                                  serverUrl: wsURL]
                                                 addRecognitionDelegate: self]
                                                userName: username password: password];

```
É possível adicionar vários *delegates* de reconhecimento utilizando o método `addRecognitionDelegate` de `CPqDASRSpeechRecognizerBuilder`. Todas as instâncias devem implementar o protocolo [CPqDASRRecognitionDelegate](CPqDASR/CPqDASR/Interface/CPqDASRRecognitionDelegate.h). 

Após isso, basta criar uma instância de `CPqDASRSpeechRecognizer` utilizando o método `build` de `CPqDASRSpeechRecognizerBuilder`.

**Swift**:
```swift
let recognizer = builder?.build()
```
**Objective-C**:
```objc
CPqDASRSpeechRecognizer * recognizer = [builder build];
```

### Criar uma fonte de áudio para o reconhecimento
Para que o ASR possa realizar um reconhecimento de fala é preciso fornecer uma fonte de áudio para a instância de `CPqDASRSpeechRecognizer`. Uma fonte de áudio pode ser qualquer classe que implemente o protocolo [CPqDASRAudioSource](CPqDASR/CPqDASR/Interface/CPqDASRAudioSource.h).

O framework CPqDASR já fornece três fontes de áudio que podem ser utilizadas pela aplicação para realizar um reconhecimento.

#### CPqDASRMicAudioSource
Fonte de áudio que utiliza o microfone do dispositivo para realizar a captura.
Crie uma instância de `CPqDASRMicAudioSource` conforme exemplo:

**Swift**:
```swift
let audioSource = CPqDASRMicAudioSource(delegate: self, andSampleRate: captureSampleRate)
```
**Objective-C**:
```objc
[[CPqDASRMicAudioSource alloc] initWithDelegate:self andSampleRate: captureSampleRate]; 
```
Deve ser fornecido um *delegate* responsável por implementar o protocol [CPqDASRMicAudioSourceDelegate](CPqDASR/CPqDASR/Recognizer/CPqDASRMicAudioSource.h).

Também deve ser fornecido a taxa de amostragem para captura de áudio, podendo ser 8 ou 16 KHz.

#### CPqDASRFileAudioSource
Fonte de áudio que utiliza um arquivo fornecido pela aplicação para realizar o reconhecimento.
Crie uma instância de `CPqDASRFileAudioSource` conforme exemplo:

**Swift**:
```swift
let audioSource = CPqDASRFileAudioSource(filePath: audioPath)
```
**Objective-C**:
```objc
CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath: audioPath];
```
`audioPath` é o caminho para o arquivo de áudio a ser reconhecido.

#### CPqDASRBufferAudioSource
Fonte de áudio que utiliza amostras fornecidas pela aplicação para realizar o reconhecimento.
Crie uma instância de `CPqDASRBufferAudioSource` conforme exemplo:

**Swift**:
```swift
let audioSource = CPqDASRBufferAudioSource();
```
**Objective-C**:
```objc
CPqDASRBufferAudioSource * audioSource = [[CPqDASRBufferAudioSource alloc] init];
```
Após iniciar o reconhecimento, a aplicação é responsável por fornecer amostras de áudio através do métodos `write:`.

**Swift**:
```swift
audioSource.write(data);
```
**Objective-C**:
```objc
[audioSource write: data];
```

### Criar modelo de língua
Para realizar um reconhecimento também é necessário fornecer um modelo de língua para o reconhecedor.
**Swift**:
```swift
let languageModelList = CPqDASRLanguageModelList();
languageModelList.addURI("builtin:slm/general")
```
**Objective-C**:
```objc
CPqDASRLanguageModelList * languageModelList = [[CPqDASRLanguageModelList alloc] init];
[languageModelList addURI: "builtin:slm/general"];
```
O exemplo acima define um modelo de fala livre interno.

### Realizar um reconhecimento
Após criar um *builder*, uma fonte de áudio e definir o modelo de língua a ser utilizado, é possível iniciar uma sessão reconhecimento.

**Swift**:
```swift
recognizer.recognize(audioSource, languageModel: languageModelList)
```
**Objective-C**:
```objc
[recognizer recognize:audioSource languageModel: languageModelList];
```
Opcionalmente, para cada novo reconhecimento pode ser fornecido um objeto com parâmetros a serem utilizados somente para aquele reconhecimento. O objeto a ser utilizado é uma instância de [CPqDASRRecognitionConfig](CPqDASR/CPqDASR/Model/CPqDASRRecognitionConfig.h).

**Swift**:
```swift
let config = CPqDASRRecognitionConfig();
config.continuousMode = NSNumber(value: false);
config.maxSentences = NSNumber(value: 3);

recognizer.recognize(audioSource, languageModel: languageModelList, recogConfig: config)
```
**Objective-C**:
```objc
CPqDASRRecognitionConfig * config = [[CPqDASRRecognitionConfig alloc] init];
config.maxSentences = [NSNumber numberWithInteger: 3];
config.continuousMode = [NSNumber numberWithBool: NO];

[recognizer recognize:audioSource languageModel: languageModelList recogConfig: config];
```

Se tudo estiver correto, o resultado final do reconhecimento será informado através do método `cpqdASRDidReturnFinalResult` do protocolo `CPqDASRRecognitionDelegate`.

**Swift**:
```swift 
 func cpqdASRDidReturnFinalResult(_ result: CPqDASRRecognitionResult!) {
    if result.status == .recognized {
        var counter = 0;
        for alternative in result.alternatives {
            print("Alternativa [\(counter)] (score = \(alternative.score)): \(alternative.text)")
            counter = counter+1;
        }
    }       
 }
```
**Objective-C**:
```objc
- (void)cpqdASRDidReturnFinalResult:(CPqDASRRecognitionResult *)result {
    if (result.status == CPqDASRRecognitionStatusRecognized) {
        int counter = 0;
        for (CPqDASRRecognitionResultAlternative * alternative in result.alternatives) {
            NSLog(@"Alternativa %d (score=%ld): %@", counter, alternative.score, alternative.text);
            counter++;
        }
    }
}
```
Licença
-------

Copyright (c) 2018 CPqD. Todos os direitos reservados.

Publicado sob a licença Apache Software 2.0, veja [LICENSE](LICENSE).
