//
//  ViewController.swift
//  iNotes Synth x2
//
//  Created by Evan Escobar on 6/21/23.
//

import UIKit
import AudioKit
import DunneAudioKit
import SoundpipeAudioKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    
    // Other
    var settings_controller = SettingsViewController()
    var can_present_new_controller = true

    // UI
    var piano_string_container = UIView()
    var piano_string_dictionary = [Int: PianoStringView]()
    var synth_view = UIView()
    var synth_view_overlay = UIView()
    var synth_button_dictionary = [Int: ButtonView]()
    var synth_state_dictionary = [Int: Bool]()
    var red_octave_bar = OctaveBarView()
    var mini_bar = UIView()
    
    var settings_button = LeftButton()
    var octave_button = LeftButton()
    var sharp_button = LeftButton()
    var flat_button = LeftButton()
    
    var label_octave1 = UILabel()
    var label_octave2 = UILabel()
    var label_octave3 = UILabel()
    var label_octave4 = UILabel()
    
    var label_notes_dictionary = [Int: UILabel]()

    // Theme
    var master_theme = 1
    var color_natural = UIColor(red: 0.05, green: 0.52, blue: 1, alpha: 1)
    var color_flat = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    var color_sharp = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
    var color_octave_bar = UIColor(white: 0.5, alpha: 1)
    var color_synth = UIColor(white: 0.95, alpha: 1)
    
    // React
    var current_flat = false
    var current_sharp = false

    // Audio
    var master_scale_mode = 1 
    var master_frequency_preset = 1
    var master_midi_correction: Int {
        var value = 24
        if self.master_octave_shift == false { return value }
        if self.master_octave_shift == true { return value + 12 }
        return value
    }

    var master_key_signature = 0
    var master_major_mode = false
    var master_octave_shift = false
    
    var audio_engine = AudioEngine()
    var audio_master_mixer = Mixer()
    var audio_mixer1 = Mixer()
    var audio_mixer2 = Mixer()
    var audio_mixer3 = Mixer()
    var audio_mixer4 = Mixer()
    var envelope1: AmplitudeEnvelope!
    var envelope2: AmplitudeEnvelope!
    var envelope3: AmplitudeEnvelope!
    var envelope4: AmplitudeEnvelope!
    var morphing_osc1 = Oscillator() // sine
    var morphing_osc2 = Oscillator() // sine
    var morphing_osc3 = Oscillator() // sine
    var morphing_osc4 = Oscillator() // sine
    var second_morphing_osc1 = Oscillator() // square
    var second_morphing_osc2 = Oscillator() // square
    var second_morphing_osc3 = Oscillator() // square
    var second_morphing_osc4 = Oscillator() // square
    var fm_osc1 = FMOscillator()
    var fm_osc2 = FMOscillator()
    var fm_osc3 = FMOscillator()
    var fm_osc4 = FMOscillator()
    var sub_osc1 = Oscillator()
    var sub_osc2 = Oscillator()
    var sub_osc3 = Oscillator()
    var sub_osc4 = Oscillator()
    var stereo_delay: StereoDelay!
    var reverb: Reverb!



    var generator_soft = UIImpactFeedbackGenerator(style: .soft)
    var generator_rigid = UIImpactFeedbackGenerator(style: .rigid)
    override var prefersStatusBarHidden: Bool { return true }
    override var prefersHomeIndicatorAutoHidden: Bool { return true }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black

        
        // Settings Controller
        self.settings_controller.modalTransitionStyle = .crossDissolve
        self.settings_controller.modalPresentationStyle = .overFullScreen
        self.settings_controller.origin_controller = self

        // UI
        self.prepare_synth_state()
        self.prepare_piano_strings()
        self.color_piano_strings()
        self.prepare_synth_view()
        self.prepare_synth_buttons()
        self.prepare_synth_button_gestures()
        self.prepare_red_bar()
        self.prepare_left_buttons()
        self.prepare_left_button_gestures()
        self.prepare_labels_octaves()
        self.prepare_labels_notes()
        

        // MUSIC THEORY
        self.theory_assign_natural_minor_tags()
        
        // AudioKit
        self.audio_prepare_oscillators()
        self.audio_start_all_oscillators()
        self.audio_prepare_mixers()
        self.audio_prepare_envelopes()
        self.audio_prepare_master_mixer()
        self.audio_prepare_effects()

        self.envelope_preset1()
        self.audio_prepare_engine()

        
        // THEME
        self.restore_theme()

    }
    
    // MARK: COLOR THEMES
    
    func restore_theme() {
        let defaults = UserDefaults.standard
        var theme_number = defaults.integer(forKey: "THEME")
        if theme_number == nil { theme_number = 1 }
        self.master_theme = theme_number
        
        self.set_theme()
    }
    
    func set_theme() {
        switch self.master_theme {
        case 1:
            self.color_natural = UIColor(red: 0.05, green: 0.52, blue: 1, alpha: 1)
            self.color_flat = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
            self.color_sharp = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
            
            self.color_octave_bar = UIColor(white: 0.5, alpha: 1)
            self.color_synth = UIColor(white: 0.9, alpha: 1)
            
        case 2:
            self.color_natural = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
            self.color_flat = UIColor(red: 1, green: 0.25, blue: 0, alpha: 1)
            self.color_sharp = UIColor(red: 1, green: 0.75, blue: 0, alpha: 1)
            
            self.color_octave_bar = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
            self.color_synth = UIColor(white: 0.5, alpha: 1)

        case 3:
            self.color_natural = UIColor(red: 0.05, green: 0.52, blue: 1, alpha: 1)
            self.color_flat = UIColor(red: 0, green: 0.26, blue: 1, alpha: 1)
            self.color_sharp = UIColor(red: 0, green: 0.78, blue: 1, alpha: 1)
            
            self.color_octave_bar = UIColor(red: 0.65, green: 1, blue: 0.65, alpha: 1)
            self.color_synth = UIColor(red: 0.85, green: 0.95, blue: 1, alpha: 1)

        case 4:
            self.color_natural = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1)
            self.color_flat = UIColor(red: 1, green: 0, blue: 0.5, alpha: 1)
            self.color_sharp = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
            
            self.color_octave_bar = UIColor(red: 1, green: 0.75, blue: 0, alpha: 1)
            self.color_synth = UIColor(white: 1, alpha: 1)

        default:
            self.color_natural = UIColor(red: 0.05, green: 0.52, blue: 1, alpha: 1)
            self.color_flat = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
            self.color_sharp = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
            
            self.color_octave_bar = UIColor(white: 0.5, alpha: 1)
            self.color_synth = UIColor(white: 0.95, alpha: 1)
        }
        
        self.update_ui_colors()
    }
    
    func update_ui_colors() {
        for string in self.piano_string_dictionary.values {
            string.color_view.backgroundColor = self.color_natural
            string.flat_view.backgroundColor = self.color_flat
            string.sharp_view.backgroundColor = self.color_sharp
            
            self.synth_view.backgroundColor = self.color_synth
            self.red_octave_bar.backgroundColor = self.color_octave_bar
            self.mini_bar.backgroundColor = self.color_octave_bar
            
            self.flat_button.front_view.toon_border_color(value: self.color_flat)
            self.flat_button.back_view.backgroundColor = self.color_flat
            self.sharp_button.front_view.toon_border_color(value: self.color_sharp)
            self.sharp_button.back_view.backgroundColor = self.color_sharp
            
        }
    }
    // MARK: LABELS
    func prepare_labels_octaves() {
        
        let label_oct = UILabel()
        label_oct.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 80, width: 215, height: 30)
        label_oct.frame.origin.x = UIScreen.main.bounds.width - (55 * 4)
        label_oct.toon_label_with(text: "octave", color: .black, alignment: 1, weight: 2, size: 13)
        label_oct.alpha = 0.5
        self.view.addSubview(label_oct)
        
        
        label_octave1.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 100, width: 50, height: 30)
        label_octave2.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 100, width: 50, height: 30)
        label_octave3.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 100, width: 50, height: 30)
        label_octave4.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 100, width: 50, height: 30)

        label_octave1.frame.origin.x = UIScreen.main.bounds.width - (55 * 4)
        label_octave2.frame.origin.x = UIScreen.main.bounds.width - (55 * 3)
        label_octave3.frame.origin.x = UIScreen.main.bounds.width - (55 * 2)
        label_octave4.frame.origin.x = UIScreen.main.bounds.width - (55 * 1)
        
        label_octave1.toon_label_with(text: "1", color: UIColor.black, alignment: 1, weight: 2, size: 13)
        label_octave2.toon_label_with(text: "2", color: UIColor.black, alignment: 1, weight: 2, size: 13)
        label_octave3.toon_label_with(text: "3", color: UIColor.black, alignment: 1, weight: 2, size: 13)
        label_octave4.toon_label_with(text: "4", color: UIColor.black, alignment: 1, weight: 2, size: 13)
        
        label_octave1.alpha = 0.5
        label_octave2.alpha = 0.5
        label_octave3.alpha = 0.5
        label_octave4.alpha = 0.5

        self.view.addSubview(label_octave1)
        self.view.addSubview(label_octave2)
        self.view.addSubview(label_octave3)
        self.view.addSubview(label_octave4)

    }
    
    func prepare_labels_notes() {
        let title_dictionary = [1:"A", 2:"B", 3:"C", 4:"D", 5:"E", 6:"F", 7:"G"]
        for n in 1...7 {
            let new_label = UILabel()
            new_label.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            new_label.frame.origin.x = UIScreen.main.bounds.width - (55 * 5) - 4
            new_label.frame.origin.y = UIScreen.main.bounds.height - (CGFloat(n) * 55) - 112
            new_label.toon_label_with(text: title_dictionary[n]!, color: .black, alignment: 2, weight: 2, size: 13)
            new_label.alpha = 0.5
            self.view.addSubview(new_label)
            
            self.label_notes_dictionary[n] = new_label
        }
    }
    
    func update_note_labels() {
        switch self.master_key_signature {
        case 0:
            // A
            if self.master_scale_mode == 1 {
                for n in 1...7 {
                    let titles = ["A", "B", "C", "D", "E", "F", "G"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 2 {
                for n in 1...7 {
                    let titles = ["A", "B", "C", "D", "E", "F", "G#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 3 {
                for n in 1...7 {
                    let titles = ["A", "B", "C", "D", "E", "F#", "G#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 4 {
                for n in 1...7 {
                    let titles = ["A", "B", "C#", "D", "E", "F#", "G#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            
        case 1:
            // B flat

            if self.master_scale_mode == 1 {
                for n in 1...7 {
                    let titles = ["B♭", "C", "D♭", "E♭", "F", "G♭", "A♭"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 2 {
                for n in 1...7 {
                    let titles = ["B♭", "C", "D♭", "E♭", "F", "G♭", "A"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 3 {
                for n in 1...7 {
                    let titles = ["B♭", "C", "D♭", "E♭", "F", "G", "A"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 4 {
                for n in 1...7 {
                    let titles = ["B♭", "C", "D", "E♭", "F", "G", "A"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }

        case 2:
            // B
            if self.master_scale_mode == 1 {
                for n in 1...7 {
                    let titles = ["B", "C#", "D", "E", "F#", "G", "A"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 2 {
                for n in 1...7 {
                    let titles = ["B", "C#", "D", "E", "F#", "G", "A#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 3 {
                for n in 1...7 {
                    let titles = ["B", "C#", "D", "E", "F#", "G#", "A#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 4 {
                for n in 1...7 {
                    let titles = ["B", "C#", "D#", "E", "F#", "G#", "A#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            
        case 3:
            // C
            if self.master_scale_mode == 1 {
                for n in 1...7 {
                    let titles = ["C", "D", "E♭", "F", "G", "A♭", "B♭"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 2 {
                for n in 1...7 {
                    let titles = ["C", "D", "E♭", "F", "G", "A♭", "B"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 3 {
                for n in 1...7 {
                    let titles = ["C", "D", "E♭", "F", "G", "A", "B"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 4 {
                for n in 1...7 {
                    let titles = ["C", "D", "E", "F", "G", "A", "B"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }

        case 4:
            // D flat
            if self.master_scale_mode == 1 {
                for n in 1...7 {
                    let titles = ["D♭", "E♭", "F♭", "G♭", "A♭", "B♭♭", "C♭"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 2 {
                for n in 1...7 {
                    let titles = ["D♭", "E♭", "F♭", "G♭", "A♭", "B♭♭", "C"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 3 {
                for n in 1...7 {
                    let titles = ["D♭", "E♭", "F♭", "G♭", "A♭", "B♭", "C"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 4 {
                for n in 1...7 {
                    let titles = ["D♭", "E♭", "F", "G♭", "A♭", "B♭", "C"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }

        case 5:
            // D
            if self.master_scale_mode == 1 {
                for n in 1...7 {
                    let titles = ["D", "E", "F", "G", "A", "B♭", "C"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 2 {
                for n in 1...7 {
                    let titles = ["D", "E", "F", "G", "A", "B♭", "C#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 3 {
                for n in 1...7 {
                    let titles = ["D", "E", "F", "G", "A", "B", "C#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 4 {
                for n in 1...7 {
                    let titles = ["D", "E", "F#", "G", "A", "B", "C#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }

        case 6:
            // E flat
            if self.master_scale_mode == 1 {
                for n in 1...7 {
                    let titles = ["E♭", "F", "G♭", "A♭", "B♭", "C♭", "D♭"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 2 {
                for n in 1...7 {
                    let titles = ["E♭", "F", "G♭", "A♭", "B♭", "C♭", "D"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 3 {
                for n in 1...7 {
                    let titles = ["E♭", "F", "G♭", "A♭", "B♭", "C", "D"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 4 {
                for n in 1...7 {
                    let titles = ["E♭", "F", "G", "A♭", "B♭", "C", "D"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }

        case 7:
            // E
            if self.master_scale_mode == 1 {
                for n in 1...7 {
                    let titles = ["E", "F#", "G", "A", "B", "C", "D"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 2 {
                for n in 1...7 {
                    let titles = ["E", "F#", "G", "A", "B", "C", "D#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 3 {
                for n in 1...7 {
                    let titles = ["E", "F#", "G", "A", "B", "C#", "D#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 4 {
                for n in 1...7 {
                    let titles = ["E", "F#", "G#", "A", "B", "C#", "D#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }

        case 8:
            // F
            if self.master_scale_mode == 1 {
                for n in 1...7 {
                    let titles = ["F", "G", "A♭", "B♭", "C", "D♭", "E♭"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 2 {
                for n in 1...7 {
                    let titles = ["F", "G", "A♭", "B♭", "C", "D♭", "E"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 3 {
                for n in 1...7 {
                    let titles = ["F", "G", "A♭", "B♭", "C", "D", "E"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 4 {
                for n in 1...7 {
                    let titles = ["F", "G", "A", "B♭", "C", "D", "E"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }

        case 9:
            // G flat
            if self.master_scale_mode == 1 {
                for n in 1...7 {
                    let titles = ["G♭", "A♭", "B♭♭", "C♭", "D♭", "E♭♭", "F♭"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 2 {
                for n in 1...7 {
                    let titles = ["G♭", "A♭", "B♭♭", "C♭", "D♭", "E♭♭", "F"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 3 {
                for n in 1...7 {
                    let titles = ["G♭", "A♭", "B♭♭", "C♭", "D♭", "E♭", "F"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 4 {
                for n in 1...7 {
                    let titles = ["G♭", "A♭", "B♭", "C♭", "D♭", "E♭", "F"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }

        case 10:
            // G
            if self.master_scale_mode == 1 {
                for n in 1...7 {
                    let titles = ["G", "A", "B♭", "C", "D", "E♭", "F"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 2 {
                for n in 1...7 {
                    let titles = ["G", "A", "B♭", "C", "D", "E♭", "F#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 3 {
                for n in 1...7 {
                    let titles = ["G", "A", "B♭", "C", "D", "E", "F#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 4 {
                for n in 1...7 {
                    let titles = ["G", "A", "B", "C", "D", "E", "F#"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            
        case 11:
            // A flat
            if self.master_scale_mode == 1 {
                for n in 1...7 {
                    let titles = ["A♭", "B♭", "C♭", "D♭", "E♭", "F♭", "G♭"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 2 {
                for n in 1...7 {
                    let titles = ["A♭", "B♭", "C♭", "D♭", "E♭", "F♭", "G"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 3 {
                for n in 1...7 {
                    let titles = ["A♭", "B♭", "C♭", "D♭", "E♭", "F", "G"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
            if self.master_scale_mode == 4 {
                for n in 1...7 {
                    let titles = ["A♭", "B♭", "C", "D♭", "E♭", "F", "G"]
                    let label = self.label_notes_dictionary[n]
                    label?.text = titles[n - 1]
                }
            }
        default: print("Update note labels function defaulted.")
        }
    }
        
    // MARK: AUDIO
    func audio_prepare_oscillators() {
        // Morphing Oscillators
        self.morphing_osc1 = Oscillator(waveform: Table(.triangle))
        self.morphing_osc2 = Oscillator(waveform: Table(.triangle))
        self.morphing_osc3 = Oscillator(waveform: Table(.triangle))
        self.morphing_osc4 = Oscillator(waveform: Table(.triangle))

        self.morphing_osc1.amplitude = 1
        self.morphing_osc2.amplitude = 1
        self.morphing_osc3.amplitude = 1
        self.morphing_osc4.amplitude = 1

        self.morphing_osc1.frequency = 440
        self.morphing_osc2.frequency = 440
        self.morphing_osc3.frequency = 440
        self.morphing_osc4.frequency = 440

        
        // Second Morphing Oscillatorss
        self.second_morphing_osc1 = Oscillator(waveform: Table(.triangle))
        self.second_morphing_osc2 = Oscillator(waveform: Table(.triangle))
        self.second_morphing_osc3 = Oscillator(waveform: Table(.triangle))
        self.second_morphing_osc4 = Oscillator(waveform: Table(.triangle))


        self.second_morphing_osc1.amplitude = 1
        self.second_morphing_osc2.amplitude = 1
        self.second_morphing_osc3.amplitude = 1
        self.second_morphing_osc4.amplitude = 1

        self.second_morphing_osc1.frequency = 440
        self.second_morphing_osc2.frequency = 440
        self.second_morphing_osc3.frequency = 440
        self.second_morphing_osc4.frequency = 440

        
        // Sub Oscillators
        self.sub_osc1 = Oscillator(waveform: Table(.sine))
        self.sub_osc2 = Oscillator(waveform: Table(.sine))
        self.sub_osc3 = Oscillator(waveform: Table(.sine))
        self.sub_osc4 = Oscillator(waveform: Table(.sine))

        self.sub_osc1.amplitude = 1
        self.sub_osc2.amplitude = 1
        self.sub_osc3.amplitude = 1
        self.sub_osc4.amplitude = 1

        self.sub_osc1.frequency = 440 / 2
        self.sub_osc2.frequency = 440 / 2
        self.sub_osc3.frequency = 440 / 2
        self.sub_osc4.frequency = 440 / 2

        // FM Oscillators
        self.fm_osc1.amplitude = 1
        self.fm_osc2.amplitude = 1
        self.fm_osc3.amplitude = 1
        self.fm_osc4.amplitude = 1

        self.fm_osc1.baseFrequency = 440
        self.fm_osc2.baseFrequency = 440
        self.fm_osc3.baseFrequency = 440
        self.fm_osc4.baseFrequency = 440

        self.fm_osc1.carrierMultiplier = 1
        self.fm_osc2.carrierMultiplier = 1
        self.fm_osc3.carrierMultiplier = 1
        self.fm_osc4.carrierMultiplier = 1

        self.fm_osc1.modulatingMultiplier = 1
        self.fm_osc2.modulatingMultiplier = 1
        self.fm_osc3.modulatingMultiplier = 1
        self.fm_osc4.modulatingMultiplier = 1

        self.fm_osc1.modulationIndex = 1
        self.fm_osc2.modulationIndex = 1
        self.fm_osc3.modulationIndex = 1
        self.fm_osc4.modulationIndex = 1

    }
    
    func audio_start_all_oscillators() {
        self.morphing_osc1.start()
        self.morphing_osc2.start()
        self.morphing_osc3.start()
        self.morphing_osc4.start()

        self.second_morphing_osc1.start()
        self.second_morphing_osc2.start()
        self.second_morphing_osc3.start()
        self.second_morphing_osc4.start()

        self.fm_osc1.start()
        self.fm_osc2.start()
        self.fm_osc3.start()
        self.fm_osc4.start()

        self.sub_osc1.start()
        self.sub_osc2.start()
        self.sub_osc3.start()
        self.sub_osc4.start()
    }

    func audio_prepare_mixers() {
        self.audio_mixer1 = Mixer([self.morphing_osc1, self.second_morphing_osc1, self.sub_osc1, self.fm_osc1])
        self.audio_mixer2 = Mixer([self.morphing_osc2, self.second_morphing_osc2, self.sub_osc2, self.fm_osc2])
        self.audio_mixer3 = Mixer([self.morphing_osc3, self.second_morphing_osc3, self.sub_osc3, self.fm_osc3])
        self.audio_mixer4 = Mixer([self.morphing_osc4, self.second_morphing_osc4, self.sub_osc4, self.fm_osc4])

//        self.audio_mixer1 = Mixer([self.sub_osc1, self.fm_osc1])
//        self.audio_mixer2 = Mixer([self.sub_osc2, self.fm_osc2])
//        self.audio_mixer3 = Mixer([self.sub_osc3, self.fm_osc3])


    }

    func audio_prepare_envelopes() {
        self.envelope1 = AmplitudeEnvelope(self.audio_mixer1)
        self.envelope2 = AmplitudeEnvelope(self.audio_mixer2)
        self.envelope3 = AmplitudeEnvelope(self.audio_mixer3)
        self.envelope4 = AmplitudeEnvelope(self.audio_mixer4)

        self.envelope1.attackDuration = 0.01
        self.envelope2.attackDuration = 0.01
        self.envelope3.attackDuration = 0.01
        self.envelope4.attackDuration = 0.01

        self.envelope1.decayDuration = 0
        self.envelope2.decayDuration = 0
        self.envelope3.decayDuration = 0
        self.envelope4.decayDuration = 0

        self.envelope1.sustainLevel = 1
        self.envelope2.sustainLevel = 1
        self.envelope3.sustainLevel = 1
        self.envelope4.sustainLevel = 1

        self.envelope1.releaseDuration = 0.01
        self.envelope2.releaseDuration = 0.01
        self.envelope3.releaseDuration = 0.01
        self.envelope4.releaseDuration = 0.01

    }

    func audio_prepare_master_mixer() {
        self.audio_master_mixer = Mixer([self.envelope1, self.envelope2, self.envelope3, self.envelope4])
    }

    func audio_prepare_effects() {
        self.stereo_delay = StereoDelay(self.audio_master_mixer)
        self.stereo_delay.dryWetMix = 1
        self.stereo_delay.feedback = 0
        self.stereo_delay.time = 0
        
        self.reverb = Reverb(self.stereo_delay)
        self.reverb.dryWetMix = 0
    }
    
    func audio_prepare_engine() {
        self.audio_engine.output = self.reverb
        try? self.audio_engine.start()
        
        self.envelope1.openGate()
        self.envelope2.openGate()
        self.envelope3.openGate()
        self.envelope4.openGate()

        self.envelope1.closeGate()
        self.envelope2.closeGate()
        self.envelope3.closeGate()
        self.envelope4.closeGate()
    }
    
    //MARK: EFFECTS
    func set_reverb(value: Float) {
        self.reverb.dryWetMix = value
    }
    
    func set_delay(value: Int) {
        switch value {
        case 0:
            self.stereo_delay.dryWetMix = 1
            self.stereo_delay.feedback = 0
            self.stereo_delay.time = 0
        case 1:
            self.stereo_delay.dryWetMix = 0.5
            self.stereo_delay.feedback = 0.1
            self.stereo_delay.time = 0.5
        case 2:
            self.stereo_delay.dryWetMix = 0.5
            self.stereo_delay.feedback = 0.25
            self.stereo_delay.time = 0.5
        case 3:
            self.stereo_delay.dryWetMix = 0.5
            self.stereo_delay.feedback = 0.5
            self.stereo_delay.time = 0.5
        default:
            self.stereo_delay.dryWetMix = 1
            self.stereo_delay.feedback = 0
            self.stereo_delay.time = 0
        }
    }
    
    



    
    // MARK: ENVELOPE PRESETS
    func envelope_preset1() {
        self.envelope1.attackDuration = 0.01
        self.envelope2.attackDuration = 0.01
        self.envelope3.attackDuration = 0.01
        self.envelope4.attackDuration = 0.01

        self.envelope1.decayDuration = 0
        self.envelope2.decayDuration = 0
        self.envelope3.decayDuration = 0
        self.envelope4.decayDuration = 0

        self.envelope1.sustainLevel = 1
        self.envelope2.sustainLevel = 1
        self.envelope3.sustainLevel = 1
        self.envelope4.sustainLevel = 1

        self.envelope1.releaseDuration = 0.01
        self.envelope2.releaseDuration = 0.01
        self.envelope3.releaseDuration = 0.01
        self.envelope4.releaseDuration = 0.01
    }
    
    func envelope_preset2() {
        self.envelope1.attackDuration = 0.01
        self.envelope2.attackDuration = 0.01
        self.envelope3.attackDuration = 0.01
        self.envelope4.attackDuration = 0.01

        self.envelope1.decayDuration = 0
        self.envelope2.decayDuration = 0
        self.envelope3.decayDuration = 0
        self.envelope4.decayDuration = 0

        self.envelope1.sustainLevel = 1
        self.envelope2.sustainLevel = 1
        self.envelope3.sustainLevel = 1
        self.envelope4.sustainLevel = 1

        self.envelope1.releaseDuration = 0.2
        self.envelope2.releaseDuration = 0.2
        self.envelope3.releaseDuration = 0.2
        self.envelope4.releaseDuration = 0.2
    }

    func envelope_preset3() {
        self.envelope1.attackDuration = 0.01
        self.envelope2.attackDuration = 0.01
        self.envelope3.attackDuration = 0.01
        self.envelope4.attackDuration = 0.01

        self.envelope1.decayDuration = 0.025
        self.envelope2.decayDuration = 0.025
        self.envelope3.decayDuration = 0.025
        self.envelope4.decayDuration = 0.025

        self.envelope1.sustainLevel = 0.1
        self.envelope2.sustainLevel = 0.1
        self.envelope3.sustainLevel = 0.1
        self.envelope4.sustainLevel = 0.1

        self.envelope1.releaseDuration = 0.2
        self.envelope2.releaseDuration = 0.2
        self.envelope3.releaseDuration = 0.2
        self.envelope4.releaseDuration = 0.2
    }

    func envelope_preset4() {
        self.envelope1.attackDuration = 1
        self.envelope2.attackDuration = 1
        self.envelope3.attackDuration = 1
        self.envelope4.attackDuration = 1

        self.envelope1.decayDuration = 0
        self.envelope2.decayDuration = 0
        self.envelope3.decayDuration = 0
        self.envelope4.decayDuration = 0

        self.envelope1.sustainLevel = 1
        self.envelope2.sustainLevel = 1
        self.envelope3.sustainLevel = 1
        self.envelope4.sustainLevel = 1

        self.envelope1.releaseDuration = 0.2
        self.envelope2.releaseDuration = 0.2
        self.envelope3.releaseDuration = 0.2
        self.envelope4.releaseDuration = 0.2
    }

    
    // MARK: Frequency Presets

    func frequency_preset1(midi_ID: Int, synth: Int) {
        let correction_to_A = 20
        let correction_personal = self.master_midi_correction
        let midi_value = midi_ID + correction_to_A + correction_personal
        
        if synth == 1 {
            self.morphing_osc1.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc1.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.fm_osc1.baseFrequency = AUValue(midi_value).midiNoteToFrequency()
            self.sub_osc1.frequency = AUValue(midi_value).midiNoteToFrequency() / 2
        }
        
        if synth == 2 {
            self.morphing_osc2.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc2.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.fm_osc2.baseFrequency = AUValue(midi_value).midiNoteToFrequency()
            self.sub_osc2.frequency = AUValue(midi_value).midiNoteToFrequency() / 2
        }
        
        if synth == 3 {
            self.morphing_osc3.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc3.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.fm_osc3.baseFrequency = AUValue(midi_value).midiNoteToFrequency()
            self.sub_osc3.frequency = AUValue(midi_value).midiNoteToFrequency() / 2
        }
        if synth == 4 {
            self.morphing_osc4.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc4.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.fm_osc4.baseFrequency = AUValue(midi_value).midiNoteToFrequency()
            self.sub_osc4.frequency = AUValue(midi_value).midiNoteToFrequency() / 2
        }

    }
    
    func frequency_preset2(midi_ID: Int, synth: Int) {
        let correction_to_A = 20
        let correction_personal = self.master_midi_correction
        let midi_value = midi_ID + correction_to_A + correction_personal
        
        if synth == 1 {
            self.morphing_osc1.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc1.frequency = (AUValue(midi_value).midiNoteToFrequency() * 1.18920454545)
            self.fm_osc1.baseFrequency = (AUValue(midi_value).midiNoteToFrequency() * 1.18920454545) / 2
            self.sub_osc1.frequency = AUValue(midi_value).midiNoteToFrequency() / 2
        }
        
        if synth == 2 {
            self.morphing_osc2.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc2.frequency = (AUValue(midi_value).midiNoteToFrequency() * 1.18920454545)
            self.fm_osc2.baseFrequency = (AUValue(midi_value).midiNoteToFrequency() * 1.18920454545)  / 2
            self.sub_osc2.frequency = AUValue(midi_value).midiNoteToFrequency() / 2
        }
        
        if synth == 3 {
            self.morphing_osc3.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc3.frequency = (AUValue(midi_value).midiNoteToFrequency() * 1.18920454545)
            self.fm_osc3.baseFrequency = (AUValue(midi_value).midiNoteToFrequency() * 1.18920454545) / 2
            self.sub_osc3.frequency = AUValue(midi_value).midiNoteToFrequency() / 2
        }
        if synth == 4 {
            self.morphing_osc4.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc4.frequency = (AUValue(midi_value).midiNoteToFrequency() * 1.18920454545)
            self.fm_osc4.baseFrequency = (AUValue(midi_value).midiNoteToFrequency() * 1.18920454545) / 2
            self.sub_osc4.frequency = AUValue(midi_value).midiNoteToFrequency() / 2
        }

    }

    func frequency_preset3(midi_ID: Int, synth: Int) {
        let correction_to_A = 20
        let correction_personal = self.master_midi_correction
        let midi_value = midi_ID + correction_to_A + correction_personal
        
        if synth == 1 {
            self.morphing_osc1.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc1.frequency = (AUValue(midi_value).midiNoteToFrequency() * 1.49829545455)
            self.fm_osc1.baseFrequency = AUValue(midi_value).midiNoteToFrequency() / 2
            self.sub_osc1.frequency = (AUValue(midi_value).midiNoteToFrequency() * 1.49829545455) / 2
        }
        
        if synth == 2 {
            self.morphing_osc2.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc2.frequency = (AUValue(midi_value).midiNoteToFrequency() * 1.49829545455)
            self.fm_osc2.baseFrequency = AUValue(midi_value).midiNoteToFrequency() / 2
            self.sub_osc2.frequency = (AUValue(midi_value).midiNoteToFrequency() * 1.49829545455) / 2
        }
        
        if synth == 3 {
            self.morphing_osc3.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc3.frequency = (AUValue(midi_value).midiNoteToFrequency() * 1.49829545455)
            self.fm_osc3.baseFrequency = AUValue(midi_value).midiNoteToFrequency() / 2
            self.sub_osc3.frequency = (AUValue(midi_value).midiNoteToFrequency() * 1.49829545455) / 2
        }
        if synth == 4 {
            self.morphing_osc4.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc4.frequency = (AUValue(midi_value).midiNoteToFrequency() * 1.49829545455)
            self.fm_osc4.baseFrequency = AUValue(midi_value).midiNoteToFrequency() / 2
            self.sub_osc4.frequency = (AUValue(midi_value).midiNoteToFrequency() * 1.49829545455) / 2
        }

    }

    func frequency_preset4(midi_ID: Int, synth: Int) {
        let correction_to_A = 20
        let correction_personal = self.master_midi_correction
        let midi_value = midi_ID + correction_to_A + correction_personal
        
        if synth == 1 {
            self.morphing_osc1.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc1.frequency = AUValue(midi_value).midiNoteToFrequency() * 2
            self.fm_osc1.baseFrequency = AUValue(midi_value).midiNoteToFrequency() / 2
            self.sub_osc1.frequency = AUValue(midi_value).midiNoteToFrequency() / 4
        }
        
        if synth == 2 {
            self.morphing_osc2.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc2.frequency = AUValue(midi_value).midiNoteToFrequency() * 2
            self.fm_osc2.baseFrequency = AUValue(midi_value).midiNoteToFrequency() / 2
            self.sub_osc2.frequency = AUValue(midi_value).midiNoteToFrequency() / 4
        }
        
        if synth == 3 {
            self.morphing_osc3.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc3.frequency = AUValue(midi_value).midiNoteToFrequency() * 2
            self.fm_osc3.baseFrequency = AUValue(midi_value).midiNoteToFrequency() / 2
            self.sub_osc3.frequency = AUValue(midi_value).midiNoteToFrequency() / 4
        }
        if synth == 4 {
            self.morphing_osc4.frequency = AUValue(midi_value).midiNoteToFrequency()
            self.second_morphing_osc4.frequency = AUValue(midi_value).midiNoteToFrequency() * 2
            self.fm_osc4.baseFrequency = AUValue(midi_value).midiNoteToFrequency() / 2
            self.sub_osc4.frequency = AUValue(midi_value).midiNoteToFrequency() / 4
        }
    }



    
    // MARK: UI
    func prepare_synth_state() {
        self.synth_state_dictionary = [1: false, 2:false, 3:false, 4:false]
    }
    
    func prepare_piano_strings() {
        self.piano_string_container.frame = UIScreen.main.bounds
        self.piano_string_container.backgroundColor = .clear
        self.view.addSubview(self.piano_string_container)
        
        for n in 1...72 {
            let new_piano_string = PianoStringView()
            new_piano_string.initialize_piano_string_view()
            new_piano_string.frame.origin.x += CGFloat(n - 1) * 4
            new_piano_string.frame.origin.x += (UIScreen.main.bounds.width - 288) / 2
            
            self.piano_string_dictionary[n] = new_piano_string
            self.piano_string_container.addSubview(new_piano_string)
        }
    }

    func color_piano_strings() {
        var counter = 1
        for n in 1...72 {
            let piano_string = self.piano_string_dictionary[n]
            piano_string?.back_view.backgroundColor = UIColor(white: 0.1, alpha: 1)
            
            if counter == 2 { piano_string?.back_view.backgroundColor = UIColor(white: 0.2, alpha: 1) }
            if counter == 5 { piano_string?.back_view.backgroundColor = UIColor(white: 0.2, alpha: 1) }
            if counter == 7 { piano_string?.back_view.backgroundColor = UIColor(white: 0.2, alpha: 1) }
            if counter == 10 { piano_string?.back_view.backgroundColor = UIColor(white: 0.2, alpha: 1) }
            if counter == 12 { piano_string?.back_view.backgroundColor = UIColor(white: 0.2, alpha: 1) }
            
            counter += 1
            if counter == 13 { counter = 1 }
        }
    }
    
    func prepare_synth_view() {
        self.synth_view.frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 150)
        self.synth_view.toon_view_with(background: UIColor(white: 0.9, alpha: 1), shadow_radius: 10, shadow_opacity: 1, corner_radius: 20)
        self.view.addSubview(self.synth_view)
        
        self.synth_view_overlay.frame = self.synth_view.bounds
        self.synth_view_overlay.backgroundColor = .clear
        self.synth_view_overlay.layer.cornerRadius = 20
        self.synth_view_overlay.clipsToBounds = true
        self.synth_view_overlay.toon_gradient_with(tint: UIColor(white: 0, alpha: 0.5), flip: true)
        self.synth_view.addSubview(self.synth_view_overlay)
        
        let view100 = UIView()
        view100.frame = CGRect(x: 0, y: self.synth_view.bounds.height - 95, width: UIScreen.main.bounds.width, height: 95)
        view100.backgroundColor = UIColor(white: 0, alpha: 0)
        self.synth_view.addSubview(view100)

    }

    func prepare_synth_buttons() {
        for n in 1...7 {
            let new_button1 = ButtonView()
            let new_button2 = ButtonView()
            let new_button3 = ButtonView()
            let new_button4 = ButtonView()

            new_button1.initialize_button_view(text1: "\(n)", text2: "A", ID: 10 + n)
            new_button2.initialize_button_view(text1: "\(n)", text2: "A", ID: 20 + n)
            new_button3.initialize_button_view(text1: "\(n)", text2: "A", ID: 30 + n)
            new_button4.initialize_button_view(text1: "\(n)", text2: "A", ID: 40 + n)
            
            new_button1.frame.origin.x = UIScreen.main.bounds.width - (55 * 4)
            new_button2.frame.origin.x = UIScreen.main.bounds.width - (55 * 3)
            new_button3.frame.origin.x = UIScreen.main.bounds.width - (55 * 2)
            new_button4.frame.origin.x = UIScreen.main.bounds.width - (55 * 1)
            
            new_button1.frame.origin.y = self.synth_view.bounds.height - (CGFloat(n) * 55) - 95
            new_button2.frame.origin.y = self.synth_view.bounds.height - (CGFloat(n) * 55) - 95
            new_button3.frame.origin.y = self.synth_view.bounds.height - (CGFloat(n) * 55) - 95
            new_button4.frame.origin.y = self.synth_view.bounds.height - (CGFloat(n) * 55) - 95

            self.synth_button_dictionary[10 + n] = new_button1
            self.synth_button_dictionary[20 + n] = new_button2
            self.synth_button_dictionary[30 + n] = new_button3
            self.synth_button_dictionary[40 + n] = new_button4

            self.synth_view.addSubview(new_button1)
            self.synth_view.addSubview(new_button2)
            self.synth_view.addSubview(new_button3)
            self.synth_view.addSubview(new_button4)
        }
    }

    func prepare_synth_button_gestures() {
        for value in self.synth_button_dictionary.values {
            let touch = SynthLongPressGestureRecognizer(target: self, action: #selector(handle_synth_button_touch(gesture:)))
            touch.delegate = self
            touch.minimumPressDuration = 0
            touch.synth_state = 0
            value.addGestureRecognizer(touch)
        }
    }
    
    func prepare_red_bar() {
                
        let shadow_view2 = UIView()
        shadow_view2.frame = CGRect(x: 0, y: 136, width: UIScreen.main.bounds.width, height: 14)
        shadow_view2.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.view.addSubview(shadow_view2)
        
        let x_coord = ((UIScreen.main.bounds.width) - (CGFloat(72 * 4))) / 2
        self.red_octave_bar = OctaveBarView()
        self.red_octave_bar.frame = CGRect(x: x_coord, y: 140, width: 240, height: 6)
        self.red_octave_bar.toon_view_with(background: UIColor(white: 0.5, alpha: 1), shadow_radius: 5, shadow_opacity: 0.5, corner_radius: 3)
        self.view.addSubview(self.red_octave_bar)
        
    }
    
    func prepare_left_buttons() {
        self.settings_button = LeftButton()
        self.settings_button.initialize_button(button_ID: 1, synth_bounds: self.synth_view.bounds)
        self.synth_view.addSubview(self.settings_button)
        
        self.octave_button = LeftButton()
        self.octave_button.initialize_button(button_ID: 2, synth_bounds: self.synth_view.bounds)
        self.synth_view.addSubview(self.octave_button)
        self.mini_bar = self.octave_button.mini_octave_view
        
        self.sharp_button = LeftButton()
        self.sharp_button.initialize_button(button_ID: 3, synth_bounds: self.synth_view.bounds)
        self.synth_view.addSubview(self.sharp_button)
        
        self.flat_button = LeftButton()
        self.flat_button.initialize_button(button_ID: 4, synth_bounds: self.synth_view.bounds)
        self.synth_view.addSubview(self.flat_button)
    }

    func prepare_left_button_gestures() {
        let settings_touch = UILongPressGestureRecognizer(target: self, action: #selector(handle_settings_touch(gesture:)))
        settings_touch.delegate = self
        settings_touch.minimumPressDuration = 0
        self.settings_button.addGestureRecognizer(settings_touch)
        
        let octave_touch = UILongPressGestureRecognizer(target: self, action: #selector(handle_octave_touch(gesture:)))
        octave_touch.delegate = self
        octave_touch.minimumPressDuration = 0
        self.octave_button.addGestureRecognizer(octave_touch)

        let sharp_touch = UILongPressGestureRecognizer(target: self, action: #selector(handle_sharp_touch(gesture:)))
        sharp_touch.delegate = self
        sharp_touch.minimumPressDuration = 0
        self.sharp_button.addGestureRecognizer(sharp_touch)

        let flat_touch = UILongPressGestureRecognizer(target: self, action: #selector(handle_flat_touch(gesture:)))
        flat_touch.delegate = self
        flat_touch.minimumPressDuration = 0
        self.flat_button.addGestureRecognizer(flat_touch)

        let settings_tap = UITapGestureRecognizer(target: self, action: #selector(handle_settings_tap(gesture:)))
        settings_tap.delegate = self
        self.settings_button.addGestureRecognizer(settings_tap)
        
        let octave_tap = UITapGestureRecognizer(target: self, action: #selector(handle_octave_tap(gesture:)))
        octave_tap.delegate = self
        self.octave_button.addGestureRecognizer(octave_tap)
    }
    
    // MARK: Theory
    func theory_assign_natural_minor_tags() {
        let minor_dictionary = [1:1, 2:3, 3:4, 4:6, 5:8, 6:9, 7:11]
        for n in 1...7 {
            let button1 = self.synth_button_dictionary[10 + n]
            let button2 = self.synth_button_dictionary[20 + n]
            let button3 = self.synth_button_dictionary[30 + n]
            let button4 = self.synth_button_dictionary[40 + n]
            
            button1?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 0
            button2?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 12
            button3?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 24
            button4?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 36
        }
    }
    
    func theory_assign_harmonic_minor_tags() {
        let minor_dictionary = [1:1, 2:3, 3:4, 4:6, 5:8, 6:9, 7:12]
        for n in 1...7 {
            let button1 = self.synth_button_dictionary[10 + n]
            let button2 = self.synth_button_dictionary[20 + n]
            let button3 = self.synth_button_dictionary[30 + n]
            let button4 = self.synth_button_dictionary[40 + n]
            
            button1?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 0
            button2?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 12
            button3?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 24
            button4?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 36
        }
    }

    func theory_assign_melodic_minor_tags() {
        let minor_dictionary = [1:1, 2:3, 3:4, 4:6, 5:8, 6:10, 7:12]
        for n in 1...7 {
            let button1 = self.synth_button_dictionary[10 + n]
            let button2 = self.synth_button_dictionary[20 + n]
            let button3 = self.synth_button_dictionary[30 + n]
            let button4 = self.synth_button_dictionary[40 + n]
            
            button1?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 0
            button2?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 12
            button3?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 24
            button4?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 36
        }
    }

    
    func theory_assign_major_tags() {
        let minor_dictionary = [1:1, 2:3, 3:5, 4:6, 5:8, 6:10, 7:12]
        for n in 1...7 {
            let button1 = self.synth_button_dictionary[10 + n]
            let button2 = self.synth_button_dictionary[20 + n]
            let button3 = self.synth_button_dictionary[30 + n]
            let button4 = self.synth_button_dictionary[40 + n]
            
            button1?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 0
            button2?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 12
            button3?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 24
            button4?.midi_ID = minor_dictionary[n]! + self.master_key_signature + 36
        }
    }
    
    func theory_assign_scale_mode() {
        switch self.master_scale_mode {
        case 1:
            self.theory_assign_natural_minor_tags()
        case 2:
            self.theory_assign_harmonic_minor_tags()
        case 3:
            self.theory_assign_melodic_minor_tags()
        case 4:
            self.theory_assign_major_tags()
        default:
            self.theory_assign_natural_minor_tags()
        }
    }
    


    
    // MARK: SYNTH GESTURES
    @objc func handle_synth_button_touch(gesture: SynthLongPressGestureRecognizer) {
        if gesture.state == .began {
            self.generator_rigid.impactOccurred()
            
            var midi_ID = (gesture.view as! ButtonView).midi_ID
            var adjusted_ID = midi_ID
            if self.master_octave_shift == true { adjusted_ID += 12 }

            var sharp_flat_variance = 0
            self.piano_string_container.bringSubviewToFront(self.piano_string_dictionary[adjusted_ID]!)
            if self.current_flat == true {
                sharp_flat_variance -= 1
                self.piano_string_dictionary[adjusted_ID]?.animate_flat_on()
                (gesture.view as! ButtonView).back_view.backgroundColor = self.color_flat
            }
            if self.current_sharp == true {
                sharp_flat_variance += 1
                self.piano_string_dictionary[adjusted_ID]?.animate_sharp_on()
                (gesture.view as! ButtonView).back_view.backgroundColor = self.color_sharp
            }
            if self.current_flat == false && self.current_sharp == false {
                self.piano_string_dictionary[adjusted_ID]?.animate_color_view_on()
                (gesture.view as! ButtonView).back_view.backgroundColor = self.color_natural
            }
            (gesture.view as! ButtonView).animate_color_on()
            
            print("*** *** *** ***")
            print("Using MIDI ID \(midi_ID)")
            print("*** *** *** *** ")
            
            if (self.synth_state_dictionary[1] == false) && (gesture.continue_state == true) {
                gesture.continue_state = false
                gesture.synth_state = 1
                self.synth_state_dictionary[1] = true
                
                if self.master_frequency_preset == 1 { self.frequency_preset1(midi_ID: midi_ID + sharp_flat_variance, synth: 1) }
                if self.master_frequency_preset == 2 { self.frequency_preset2(midi_ID: midi_ID + sharp_flat_variance, synth: 1) }
                if self.master_frequency_preset == 3 { self.frequency_preset3(midi_ID: midi_ID + sharp_flat_variance, synth: 1) }
                if self.master_frequency_preset == 4 { self.frequency_preset4(midi_ID: midi_ID + sharp_flat_variance, synth: 1) }

                self.envelope1.openGate()
            }
            if (self.synth_state_dictionary[2] == false) && (gesture.continue_state == true) {
                gesture.continue_state = false
                gesture.synth_state = 2
                self.synth_state_dictionary[2] = true
                
                if self.master_frequency_preset == 1 { self.frequency_preset1(midi_ID: midi_ID + sharp_flat_variance, synth: 2) }
                if self.master_frequency_preset == 2 { self.frequency_preset2(midi_ID: midi_ID + sharp_flat_variance, synth: 2) }
                if self.master_frequency_preset == 3 { self.frequency_preset3(midi_ID: midi_ID + sharp_flat_variance, synth: 2) }
                if self.master_frequency_preset == 4 { self.frequency_preset4(midi_ID: midi_ID + sharp_flat_variance, synth: 2) }

                self.envelope2.openGate()
            }
            if (self.synth_state_dictionary[3] == false) && (gesture.continue_state == true) {
                gesture.continue_state = false
                gesture.synth_state = 3
                self.synth_state_dictionary[3] = true
                
                if self.master_frequency_preset == 1 { self.frequency_preset1(midi_ID: midi_ID + sharp_flat_variance, synth: 3) }
                if self.master_frequency_preset == 2 { self.frequency_preset2(midi_ID: midi_ID + sharp_flat_variance, synth: 3) }
                if self.master_frequency_preset == 3 { self.frequency_preset3(midi_ID: midi_ID + sharp_flat_variance, synth: 3) }
                if self.master_frequency_preset == 4 { self.frequency_preset4(midi_ID: midi_ID + sharp_flat_variance, synth: 3) }

                self.envelope3.openGate()
            }
            if (self.synth_state_dictionary[4] == false) && (gesture.continue_state == true) {
                gesture.continue_state = false
                gesture.synth_state = 4
                self.synth_state_dictionary[4] = true
                
                if self.master_frequency_preset == 1 { self.frequency_preset1(midi_ID: midi_ID + sharp_flat_variance, synth: 4) }
                if self.master_frequency_preset == 2 { self.frequency_preset2(midi_ID: midi_ID + sharp_flat_variance, synth: 4) }
                if self.master_frequency_preset == 3 { self.frequency_preset3(midi_ID: midi_ID + sharp_flat_variance, synth: 4) }
                if self.master_frequency_preset == 4 { self.frequency_preset4(midi_ID: midi_ID + sharp_flat_variance, synth: 4) }

                self.envelope4.openGate()
            }

        }
        
        if gesture.state == .ended {
            (gesture.view as! ButtonView).animate_color_off()
            
            let midi_ID = (gesture.view as! ButtonView).midi_ID
            var adjusted_ID = midi_ID
            if self.master_octave_shift == true { adjusted_ID += 12 }
            
            piano_string_dictionary[adjusted_ID]?.animate_color_view_off()
            piano_string_dictionary[adjusted_ID]?.animate_sharp_off()
            piano_string_dictionary[adjusted_ID]?.animate_flat_off()

            if gesture.synth_state == 1 {
                print("ending state 1 ")
                gesture.continue_state = true
                gesture.synth_state = 0
                self.synth_state_dictionary[1] = false
                self.envelope1.closeGate()
            }
            if gesture.synth_state == 2 {
                print("ending state 2 ")
                gesture.continue_state = true
                gesture.synth_state = 0
                self.synth_state_dictionary[2] = false
                self.envelope2.closeGate()
            }
            if gesture.synth_state == 3 {
                print("ending state 3 ")
                gesture.continue_state = true
                gesture.synth_state = 0
                self.synth_state_dictionary[3] = false
                self.envelope3.closeGate()
            }
            if gesture.synth_state == 4 {
                print("ending state 4 ")
                gesture.continue_state = true
                gesture.synth_state = 0
                self.synth_state_dictionary[4] = false
                self.envelope4.closeGate()
            }
        }
    }
    
    @objc func handle_settings_touch(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.generator_soft.impactOccurred()
            (gesture.view as! LeftButton).animate_color_on()
        }
        if gesture.state == .ended {
            (gesture.view as! LeftButton).animate_color_off()
        }
    }
    
    @objc func handle_octave_touch(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.generator_soft.impactOccurred()
            (gesture.view as! LeftButton).animate_color_on()
        }
        if gesture.state == .ended {
            (gesture.view as! LeftButton).animate_color_off()
        }
    }
    
    @objc func handle_octave_tap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            switch self.master_octave_shift {
            case true:
                self.master_octave_shift = false
                self.red_octave_bar.animate_backward()
                for n in 1...72 {
                    let string = self.piano_string_dictionary[n]
                    string?.animate_color_view_off()
                }
                self.label_octave1.text = "1"
                self.label_octave2.text = "2"
                self.label_octave3.text = "3"
                self.label_octave4.text = "4"
                
            case false:
                self.master_octave_shift = true
                self.red_octave_bar.animate_forward()
                for n in 1...72 {
                    let string = self.piano_string_dictionary[n]
                    string?.animate_color_view_off()
                }
                self.label_octave1.text = "2"
                self.label_octave2.text = "3"
                self.label_octave3.text = "4"
                self.label_octave4.text = "5"

            default:
                print("Octave shift switch defaulted")
            }
        }
    }

    @objc func handle_sharp_touch(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.generator_soft.impactOccurred()
            self.sharp_button.animate_color_on()
            self.flat_button.animate_color_off()
            
            
            self.current_flat = false
            self.current_sharp = true
        }
        if gesture.state == .ended {
            self.sharp_button.animate_color_off()
            
            
            self.current_flat = false
            self.current_sharp = false
        }
    }

    @objc func handle_flat_touch(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.generator_soft.impactOccurred()
            self.flat_button.animate_color_on()
            self.sharp_button.animate_color_off()
            
            self.current_sharp = false
            self.current_flat = true
        }
        if gesture.state == .ended {
            self.flat_button.animate_color_off()
            
            self.current_sharp = false
            self.current_flat = false
        }
    }
    
    @objc func handle_settings_tap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            if self.can_present_new_controller == true {
                self.can_present_new_controller = false
                self.present(self.settings_controller, animated: true)
            }
        }
    }


}


// MARK: Synth Long Press Gesture Recognizer
class SynthLongPressGestureRecognizer: UILongPressGestureRecognizer {
    
    var synth_state = 0
    var continue_state = true
    
}




// MARK: ButtonView Class
class ButtonView: UIView {
    
    var back_view = UIView()
    var front_view = UIView()
    var main_label1 = UILabel()
    var main_label2 = UILabel()
    var button_ID = 0
    var midi_ID = 0

    func initialize_button_view(text1: String, text2: String, ID: Int) {
        self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.backgroundColor = .clear
        
        self.back_view.frame = self.bounds
        self.back_view.toon_view_with(background: UIColor(red: 0.05, green: 0.52, blue: 1, alpha: 1), shadow_radius: 2, shadow_opacity: 0.5, corner_radius: 10)
        self.addSubview(self.back_view)
        
        self.front_view.frame = self.bounds
        self.front_view.toon_view_with(background: UIColor.black, shadow_radius: 0, shadow_opacity: 0, corner_radius: 10)
        self.addSubview(self.front_view)
        
        self.main_label1.frame = self.bounds
        self.main_label1.backgroundColor = .clear
        self.main_label1.toon_label_with(text: text1, color: .white, alignment: 1, weight: 2, size: 13)
        self.addSubview(self.main_label1)
        
        self.main_label2.frame = self.bounds
        self.main_label2.backgroundColor = .clear
        self.main_label2.toon_label_with(text: text2, color: .white, alignment: 1, weight: 2, size: 13)
        self.addSubview(self.main_label2)
        
        self.back_view.toon_border_color(value: UIColor(white: 0, alpha: 0.5))
        self.back_view.toon_border_width(value: 0)
        self.main_label2.alpha = 0
    }
    
    func animate_color_on() {
        UIView.animate(withDuration: 0, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.front_view.alpha = 0
            self.main_label1.textColor = UIColor.black
        }
    }
    
    func animate_color_off() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.front_view.alpha = 1
            self.main_label1.textColor = UIColor.white
        }
    }

    func animate_label2_on() {
        self.main_label2.alpha = 0
        self.main_label2.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.main_label1.alpha = 0
            self.main_label1.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.main_label2.alpha = 1
                self.main_label2.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        })
    }
    
    func animate_label2_off() {
        self.main_label1.alpha = 0
        self.main_label1.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.main_label2.alpha = 0
            self.main_label2.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.main_label1.alpha = 1
                self.main_label1.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        })
    }
    
}

// MARK: PianoStringView Class
class PianoStringView: UIView {
    
    var back_view = UIView()
    var color_view = UIView()
    var flat_view = UIView()
    var sharp_view = UIView()

    func initialize_piano_string_view() {
        self.frame = CGRect(x: 0, y: 0, width: 3, height: UIScreen.main.bounds.height)
        self.backgroundColor = .clear
        
        self.back_view.frame = self.bounds
        self.back_view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        self.addSubview(self.back_view)
        
        self.color_view.frame = self.bounds
        self.color_view.toon_view_with(background: UIColor(red: 0.05, green: 0.52, blue: 1, alpha: 1), shadow_radius: 0, shadow_opacity: 0, corner_radius: 0)
        self.addSubview(self.color_view)
        
        self.flat_view.frame = self.bounds
        self.flat_view.toon_view_with(background: UIColor(red: 1, green: 0, blue: 0, alpha: 1), shadow_radius: 0, shadow_opacity: 0, corner_radius: 0)
        self.addSubview(self.flat_view)
        
        self.sharp_view.frame = self.bounds
        self.sharp_view.toon_view_with(background: UIColor(red: 1, green: 0.5, blue: 0, alpha: 1), shadow_radius: 0, shadow_opacity: 0, corner_radius: 0)
        self.addSubview(self.sharp_view)
        
        self.flat_view.frame.origin.x -= 4
        self.sharp_view.frame.origin.x += 4
        
        self.sharp_view.alpha = 0
        self.flat_view.alpha = 0
        self.color_view.alpha = 0
    }

    func animate_color_view_on() {
        self.flat_view.alpha = 0
        self.sharp_view.alpha = 0
        
        UIView.animate(withDuration: 0, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.color_view.alpha = 1
            self.color_view.toon_shadow_with(radius: 2, opacity: 1)
        }
    }
    func animate_color_view_off() {
        self.flat_view.alpha = 0
        self.sharp_view.alpha = 0

        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.color_view.alpha = 0
            self.color_view.toon_shadow_with(radius: 0, opacity: 0)
        }
    }
    
    func animate_sharp_on() {
        self.color_view.alpha = 0
        UIView.animateKeyframes(withDuration: 0, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.sharp_view.alpha = 1
            self.sharp_view.toon_shadow_with(radius: 2, opacity: 1)
        }
    }
    func animate_sharp_off() {
        self.color_view.alpha = 0
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.sharp_view.alpha = 0
            self.sharp_view.toon_shadow_with(radius: 0, opacity: 0)
        }
    }

    func animate_flat_on() {
        self.color_view.alpha = 0
        UIView.animateKeyframes(withDuration: 0, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.flat_view.alpha = 1
            self.flat_view.toon_shadow_with(radius: 2, opacity: 1)
        }
    }
    func animate_flat_off() {
        self.color_view.alpha = 0
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.flat_view.alpha = 0
            self.flat_view.toon_shadow_with(radius: 0, opacity: 0)
        }
    }

    

}

// MARK: LEFT BUTTON CLASS

class LeftButton: UIView {
    
    var button_ID = 0
    var back_view = UIView()
    var front_view = UIView()
    var main_label = UILabel()
    var mini_octave_view = UIView()

    func initialize_button(button_ID: Int, synth_bounds: CGRect) {
        self.frame = CGRect(x: 5, y: 0, width: 100, height: 50)
        self.backgroundColor = UIColor.clear
        
        switch button_ID {
        case 1:
            self.frame.origin.y = synth_bounds.height - 480
            self.frame.size.height = 160
        case 2:
            self.frame.origin.y = synth_bounds.height - 315
            self.frame.size.height = 50
        case 3:
            self.frame.origin.y = synth_bounds.height - 260
            self.frame.size.height = 50
        case 4:
            self.frame.origin.y = synth_bounds.height - 205
            self.frame.size.height = 105
        default: print("LeftButton initialization switch defaulted.")
        }
        
        self.back_view.frame = self.bounds
        self.back_view.toon_view_with(background: UIColor(white: 0.65, alpha: 1), shadow_radius: 2, shadow_opacity: 0.5, corner_radius: 10)
        self.addSubview(self.back_view)
        
        self.front_view.frame = self.bounds
        self.front_view.toon_view_with(background: UIColor(white: 0, alpha: 1), shadow_radius: 0, shadow_opacity: 0, corner_radius: 10)
        self.addSubview(self.front_view)
        
        self.main_label.frame = self.bounds
        self.main_label.backgroundColor = UIColor.clear
        self.main_label.toon_label_with(text: "text", color: .white, alignment: 1, weight: 2, size: 13)
        switch button_ID {
        case 1:
            self.main_label.text = "settings"
        case 2:
            self.main_label.text = "octave"
        case 3:
            self.main_label.text = "sharp"
            self.front_view.toon_border_color(value: UIColor(red: 1, green: 0.5, blue: 0, alpha: 1))
            self.front_view.toon_border_width(value: 2)
            self.back_view.backgroundColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
        case 4:
            self.main_label.text = "flat"
            self.front_view.toon_border_color(value: UIColor(red: 1, green: 0, blue: 0, alpha: 1))
            self.front_view.toon_border_width(value: 2)
            self.back_view.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)

        default: print("LeftButton initialization text switch defaulted.")
        }
        self.addSubview(self.main_label)
        
        if button_ID == 2 {
            mini_octave_view.frame = CGRect(x: 35, y: 38, width: 30, height: 6)
            mini_octave_view.backgroundColor = UIColor(white: 0.5, alpha: 1)
            mini_octave_view.layer.cornerRadius = 3
            self.addSubview(mini_octave_view)
        }

        self.button_ID = button_ID
    }
    
    func animate_color_on() {
        UIView.animate(withDuration: 0, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
            self.front_view.alpha = 0
            self.main_label.textColor = UIColor.black
        }
    }
    
    func animate_color_off() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
            self.front_view.alpha = 1
            self.main_label.textColor = UIColor.white
        }
    }
    
}


class OctaveBarView: UIView {
    func animate_forward() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.frame.origin.x += 48
        }
    }
    
    func animate_backward() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.frame.origin.x -= 48
        }
    }

}

// MARK: TOONSTER
extension UIView {
    
    func toon_view_with(background: UIColor, shadow_radius: CGFloat, shadow_opacity: Float, corner_radius: CGFloat) {
        self.backgroundColor = background
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = shadow_radius
        self.layer.shadowOpacity = shadow_opacity
        self.layer.shadowOffset = CGSize()
        self.layer.cornerRadius = corner_radius
    }
    
    func toon_corner_radius(value: CGFloat) {
        self.layer.cornerRadius = value
    }
    
    func toon_shadow_radius(value: CGFloat) {
        self.layer.shadowRadius = value
    }
    
    func toon_shadow_opacity(value: Float) {
        self.layer.shadowOpacity = value
    }
    
    func toon_border_width(value: CGFloat) {
        self.layer.borderWidth = value
    }
    
    func toon_border_color(value: UIColor) {
        self.layer.borderColor = value.cgColor
    }
    
    func toon_shadow_with(radius: CGFloat, opacity: Float) {
        self.layer.shadowOffset = CGSize()
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = UIColor.black.cgColor
    }

    func toon_gradient_with(tint: UIColor, flip: Bool) {
        let gradientlayer = CAGradientLayer()
        gradientlayer.frame = self.bounds
        gradientlayer.colors = [tint.cgColor, UIColor.clear.cgColor]
        gradientlayer.startPoint = CGPoint.zero
        gradientlayer.endPoint = CGPoint(x: 0, y: 1)
        if flip == true {
            gradientlayer.startPoint = CGPoint(x: 0, y: 1)
            gradientlayer.endPoint = CGPoint.zero
        }
        self.layer.insertSublayer(gradientlayer, at: 0)
    }

    func toon_shrink(value: CGFloat) {
        self.frame.size.width -= value
        self.frame.size.height -= value
        self.frame.origin.x += (value / 2)
        self.frame.origin.y += (value / 2)
    }
}


extension UILabel {
    
    func toon_label_with(text: String, color: UIColor, alignment: Int, weight: Int, size: CGFloat) {
        self.text = text
        self.textColor = color

        self.textAlignment = .left
        if alignment == 0 { self.textAlignment = .left }
        if alignment == 1 { self.textAlignment = .center }
        if alignment == 2 { self.textAlignment = .right }
       
        self.font = UIFont.systemFont(ofSize: size, weight: .regular)
        if weight == 0 { self.font = UIFont.systemFont(ofSize: size, weight: .light) }
        if weight == 1 { self.font = UIFont.systemFont(ofSize: size, weight: .regular) }
        if weight == 2 { self.font = UIFont.systemFont(ofSize: size, weight: .bold) }
        if weight == 3 { self.font = UIFont.systemFont(ofSize: size, weight: .heavy) }

    }
}
