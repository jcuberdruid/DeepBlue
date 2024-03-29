# DeepBlue

![SSC2024_Social_Animated_16x9](https://github.com/jcuberdruid/DeepBlue/assets/44100876/25d9f444-d520-481c-beeb-c3c78de83599)

My submission to the 2024 Swift Student Challenge, which was selected as a Distinguished Winner!

## Technologies Used

### Modeling

I started by modeling my submarine and research sea base with clay, then captured using Reality Composer [Object Capture](https://developer.apple.com/documentation/realitykit/realitykit-object-capture).

I painted the textures for these models using [Procreate](https://procreate.com/ipad) with Apple Pencil.

For terrain, I used crowdsourced bathymetry data of the sea floor. The data started in the form of a heat map, which I converted to a height map and smoothed with a gaussian filter before generating a 3D mesh from it. It took some trial and error to ensure the resulting USDC is detailed but reasonably sized. 

### Rendering

For rendering the game, I used [RealityKit](https://developer.apple.com/augmented-reality/realitykit/), which I used for the first time. I have played with SceneKit in the past, but I really enjoyed the additional capabilities of RealityKit 2. 

To achieve a realistic underwater effect, I used a [Metal post-processing shader](https://developer.apple.com/documentation/realitykit/implementing-postprocess-effects-using-metal-compute-functions) to render distortion, "dust" particle effects, and an underwater hue.

### UI

For the UI, I used [SwiftUI](https://developer.apple.com/xcode/swiftui/) and used [TipKit](https://developer.apple.com/documentation/TipKit) for the tutorial.

## License

I'm sharing this for educational purposes only; please reach out if you'd like to reuse some part of this.
