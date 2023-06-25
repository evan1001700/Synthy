//
//  SettingsViewController.swift
//  iNotes Synth x2
//
//  Created by Evan Escobar on 6/22/23.
//

import Foundation
import UIKit
import AudioKit
import DunneAudioKit
import SoundpipeAudioKit

class SettingsViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var origin_controller: ViewController!
    var table_view = UITableView()
    var done_container = UIView()
    
    var cell_dictionary = [Int: SettingsCell]()
    var title_cell = TitleCell()
    var frequency_cell = FrequencyCell()
    var shape_cell = ShapeCell()
    var effects_cell = EffectsCell()
    var key_signature_cell = KeySignatureCell()
    var theme_cell = ThemeCell()
    
    var generator_soft = UIImpactFeedbackGenerator(style: .soft)
    var generator_rigid = UIImpactFeedbackGenerator(style: .rigid)
    override var prefersStatusBarHidden: Bool { return true }
    override var prefersHomeIndicatorAutoHidden: Bool { return true }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: VIEW DID APPEAR

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.animate_done_button_in()
    }
    
    func animate_done_button_in() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
            self.done_container.alpha = 1
            self.done_container.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.done_container.alpha = 0
        self.done_container.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
    }
    // MARK: VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.frame = UIScreen.main.bounds
        self.view.addSubview(blur)
        
        let darkening = UIView()
        darkening.frame = UIScreen.main.bounds
        darkening.backgroundColor = UIColor(white: 0, alpha: 0.25)
        self.view.addSubview(darkening)
                
    
        // Cells
        self.prepare_cells()
        
        // Table View
        self.prepare_table_view()
        
        // Prepare Done Button
        self.prepare_done_button()
        
        // Restore Theme Selection
        let theme = self.origin_controller.master_theme
        if theme == 1 { self.theme_cell.theme_segment.selectedSegmentIndex = 0 ; self.theme_cell.sublabel.text = "Default" }
        if theme == 2 { self.theme_cell.theme_segment.selectedSegmentIndex = 1 ; self.theme_cell.sublabel.text = "Autumn" }
        if theme == 3 { self.theme_cell.theme_segment.selectedSegmentIndex = 2 ; self.theme_cell.sublabel.text = "Aquatic" }
        if theme == 4 { self.theme_cell.theme_segment.selectedSegmentIndex = 3 ; self.theme_cell.sublabel.text = "Spring" }


    }
    
    func prepare_cells() {
        self.title_cell.initialize_cell(height: 200)
        self.title_cell.settings_controller_link = self
        self.cell_dictionary[0] = self.title_cell
        
        self.frequency_cell.initialize_cell(height: 180)
        self.frequency_cell.settings_controller_link = self
        self.cell_dictionary[1] = self.frequency_cell
        
        self.shape_cell.initialize_cell(height: 180)
        self.shape_cell.settings_controller_link = self
        self.cell_dictionary[2] = self.shape_cell

        self.effects_cell.initialize_cell(height: 275)
        self.effects_cell.settings_controller_link = self
        self.cell_dictionary[3] = self.effects_cell
        
        self.key_signature_cell.initialize_cell(height: 275)
        self.key_signature_cell.settings_controller_link = self
        self.cell_dictionary[4] = self.key_signature_cell

        self.theme_cell.initialize_cell(height: 180)
        self.theme_cell.settings_controller_link = self
        self.cell_dictionary[5] = self.theme_cell

    }
    
    func prepare_table_view() {
        self.table_view.delegate = self
        self.table_view.dataSource = self
        self.table_view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.table_view.backgroundColor = .clear
        self.table_view.separatorStyle = .none
        self.view.addSubview(self.table_view)
    }

    func prepare_done_button() {
        self.done_container.frame = CGRect(x: 25, y: UIScreen.main.bounds.height - 125, width: UIScreen.main.bounds.width - 50, height: 65)
        self.done_container.backgroundColor = .black
        self.done_container.toon_corner_radius(value: 20)
        self.done_container.toon_shadow_with(radius: 10, opacity: 1)
        self.view.addSubview(self.done_container)
        
        let done_label = UILabel()
        done_label.frame = self.done_container.bounds
        done_label.toon_label_with(text: "done", color: UIColor.white, alignment: 1, weight: 2, size: 25)
        self.done_container.addSubview(done_label)
        
        let done_tap = UITapGestureRecognizer(target: self, action: #selector(handle_done_tap(gesture:)))
        done_tap.delegate = self
        done_container.addGestureRecognizer(done_tap)

        self.done_container.alpha = 0
        self.done_container.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)

    }
    
    @objc func handle_done_tap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            self.generator_soft.impactOccurred()
            self.dismiss(animated: true)
            self.origin_controller.can_present_new_controller = true
        }
    }
    

    
    // MARK: CELL FOR ROW AT
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newcell = UITableViewCell()
        newcell.backgroundColor = .clear
        newcell.selectionStyle = .none
        
        let label = UILabel()
        label.frame = CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width, height: 30)
        label.toon_label_with(text: "Special thanks to the AudioKit team.", color: .white, alignment: 0, weight: 1, size: 12)
        newcell.addSubview(label)
        
        switch indexPath.row {
        case 0: return self.title_cell
        case 1: return self.frequency_cell
        case 2: return self.shape_cell
        case 3: return self.effects_cell
        case 4: return self.key_signature_cell
        case 5: return self.theme_cell
        case 6: return newcell
        default:  return newcell
        }
    }
    
    
    // MARK: HEIGHT FOR ROW AT
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell_height = self.cell_dictionary[indexPath.row]?.cell_height
        
        if cell_height == nil { return 350 }
        
        return cell_height!
    }
    
    
    // MARK: NUMBER OF ROWS IN SECTION
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }


    
}


// MARK: SETTINGS CELL
class SettingsCell: UITableViewCell {
    var settings_controller_link: SettingsViewController!
    var cell_height: CGFloat = 250
}

// MARK: TITLE CELL
class TitleCell: SettingsCell {
        
    var label_1 = UILabel()
    var label_2 = UILabel()
    var label_3 = UILabel()
    
    func initialize_cell(height: CGFloat) {
        self.cell_height = height
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.label_1.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        self.label_1.toon_label_with(text: "Synthy", color: .white, alignment: 1, weight: 2, size: 35)
        self.label_1.alpha = 0.25
        self.contentView.addSubview(self.label_1)
        
        self.label_2.frame = CGRect(x: 0, y: 35, width: UIScreen.main.bounds.width, height: 100)
        self.label_2.toon_label_with(text: "music toy & instrument", color: .white, alignment: 1, weight: 2, size: 20)
        self.label_2.alpha = 0.25
        self.contentView.addSubview(self.label_2)

        self.label_3.frame = CGRect(x: 20, y: 120, width: UIScreen.main.bounds.width, height: 100)
        self.label_3.toon_label_with(text: "Settings", color: .white, alignment: 0, weight: 2, size: 30)
        self.contentView.addSubview(self.label_3)

        
    }
    
}

// MARK: FREQUENCY CELL
class FrequencyCell: SettingsCell {
    
    var dark_box = UIView()
    var title_label = UILabel()
    var sublabel = UILabel()
    var frequency_segment = UISegmentedControl(items: ["1", "2", "3", "4"])
    
    func initialize_cell(height: CGFloat) {
        self.cell_height = height
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.dark_box.frame = self.bounds
        self.dark_box.frame.size.height -= 25
        self.dark_box.frame.size.width -= 20
        self.dark_box.frame.origin.x += 10
        self.dark_box.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.dark_box.layer.cornerRadius = 10
        self.contentView.addSubview(self.dark_box)
        
        self.title_label.frame = self.dark_box.bounds
        self.title_label.frame.size.height = 40
        self.title_label.frame.origin.x = 10
        self.title_label.toon_label_with(text: "Oscillator Tuning Presets:", color: .white, alignment: 0, weight: 2, size: 15)
        self.dark_box.addSubview(self.title_label)
        
        self.sublabel.frame = self.dark_box.bounds
        self.sublabel.frame.size.height = 40
        self.sublabel.frame.size.width -= 20
        self.sublabel.frame.origin.x += 10
        self.sublabel.frame.origin.y += 110
        self.sublabel.toon_label_with(text: "Normal", color: .white, alignment: 2, weight: 2, size: 15)
        self.sublabel.alpha = 0.5
        self.dark_box.addSubview(self.sublabel)
        
        self.frequency_segment.frame = CGRect(x: 10, y: 75, width: self.dark_box.frame.size.width - 20, height: 30)
        self.frequency_segment.selectedSegmentIndex = 0
        let atts1 = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let atts2 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        frequency_segment.setTitleTextAttributes(atts1, for: .normal)
        frequency_segment.setTitleTextAttributes(atts2, for: .selected)
        frequency_segment.addTarget(self, action: #selector(handle_frequency_segment(control:)), for: .valueChanged)
        self.dark_box.addSubview(frequency_segment)
        
    }
    
    @objc func handle_frequency_segment(control: UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 0:
            self.settings_controller_link.origin_controller.master_frequency_preset = 1
            self.sublabel.text = "Normal"
        case 1:
            self.settings_controller_link.origin_controller.master_frequency_preset = 2
            self.sublabel.text = "Minor Thirds"
        case 2:
            self.settings_controller_link.origin_controller.master_frequency_preset = 3
            self.sublabel.text = "Perfect Fifths"
        case 3:
            self.settings_controller_link.origin_controller.master_frequency_preset = 4
            self.sublabel.text = "Octaves"
        default:
            self.settings_controller_link.origin_controller.master_frequency_preset = 1
            self.sublabel.text = "Normal"
        }
    }
    
    
}


// MARK: SHAPE CELL
class ShapeCell: SettingsCell {
    
    var dark_box = UIView()
    var title_label = UILabel()
    var sublabel = UILabel()
    var shape_segment = UISegmentedControl(items: ["1", "2", "3", "4"])
    
    func initialize_cell(height: CGFloat) {
        self.cell_height = height
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.dark_box.frame = self.bounds
        self.dark_box.frame.size.height -= 25
        self.dark_box.frame.size.width -= 20
        self.dark_box.frame.origin.x += 10
        self.dark_box.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.dark_box.layer.cornerRadius = 10
        self.contentView.addSubview(self.dark_box)
        
        self.title_label.frame = self.dark_box.bounds
        self.title_label.frame.size.height = 40
        self.title_label.frame.origin.x = 10
        self.title_label.toon_label_with(text: "Amplitude Envelope Presets:", color: .white, alignment: 0, weight: 2, size: 15)
        self.dark_box.addSubview(self.title_label)
        
        self.sublabel.frame = self.dark_box.bounds
        self.sublabel.frame.size.height = 40
        self.sublabel.frame.size.width -= 20
        self.sublabel.frame.origin.x += 10
        self.sublabel.frame.origin.y += 110
        self.sublabel.toon_label_with(text: "Lead, no Release", color: .white, alignment: 2, weight: 2, size: 15)
        self.sublabel.alpha = 0.5
        self.dark_box.addSubview(self.sublabel)
        
        self.shape_segment.frame = CGRect(x: 10, y: 75, width: self.dark_box.frame.size.width - 20, height: 30)
        self.shape_segment.selectedSegmentIndex = 0
        let atts1 = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let atts2 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        shape_segment.setTitleTextAttributes(atts1, for: .normal)
        shape_segment.setTitleTextAttributes(atts2, for: .selected)
        shape_segment.addTarget(self, action: #selector(handle_shape_segment(control:)), for: .valueChanged)
        self.dark_box.addSubview(shape_segment)
        
    }
    
    @objc func handle_shape_segment(control: UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 0:
            self.settings_controller_link.origin_controller.envelope_preset1()
            self.sublabel.text = "Lead, no Release"
        case 1:
            self.settings_controller_link.origin_controller.envelope_preset2()
            self.sublabel.text = "Lead, with Release"
        case 2:
            self.settings_controller_link.origin_controller.envelope_preset3()
            self.sublabel.text = "Pluck"
        case 3:
            self.settings_controller_link.origin_controller.envelope_preset4()
            self.sublabel.text = "Pad"
        default:
            self.settings_controller_link.origin_controller.envelope_preset1()
            self.sublabel.text = "Lead, no Release"
        }
    }
    
    
}

// MARK: EFFECTS CELL
class EffectsCell: SettingsCell {
    
    var dark_box = UIView()
    var title_label = UILabel()
    var sublabel = UILabel()
    var reverb_segment = UISegmentedControl(items: ["1", "2", "3", "4"])
    
    var sublabel2 = UILabel()
    var delay_segment = UISegmentedControl(items: ["1", "2", "3", "4"])
    
    func initialize_cell(height: CGFloat) {
        self.cell_height = height
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.dark_box.frame = self.bounds
        self.dark_box.frame.size.height -= 25
        self.dark_box.frame.size.width -= 20
        self.dark_box.frame.origin.x += 10
        self.dark_box.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.dark_box.layer.cornerRadius = 10
        self.contentView.addSubview(self.dark_box)
        
        self.title_label.frame = self.dark_box.bounds
        self.title_label.frame.size.height = 40
        self.title_label.frame.origin.x = 10
        self.title_label.toon_label_with(text: "Sound Effects:", color: .white, alignment: 0, weight: 2, size: 15)
        self.dark_box.addSubview(self.title_label)
        
        self.reverb_segment.frame = CGRect(x: 10, y: 75, width: self.dark_box.frame.size.width - 20, height: 30)
        self.reverb_segment.selectedSegmentIndex = 0
        let atts1 = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let atts2 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        reverb_segment.setTitleTextAttributes(atts1, for: .normal)
        reverb_segment.setTitleTextAttributes(atts2, for: .selected)
        reverb_segment.addTarget(self, action: #selector(handle_reverb_segment(control:)), for: .valueChanged)
        self.dark_box.addSubview(reverb_segment)

        self.sublabel.frame = self.dark_box.bounds
        self.sublabel.frame.size.height = 40
        self.sublabel.frame.size.width -= 20
        self.sublabel.frame.origin.x += 10
        self.sublabel.frame.origin.y += 110
        self.sublabel.toon_label_with(text: "No Reverb", color: .white, alignment: 2, weight: 2, size: 15)
        self.sublabel.alpha = 0.5
        self.dark_box.addSubview(self.sublabel)
        
        self.delay_segment.frame = CGRect(x: 10, y: 160, width: self.dark_box.frame.size.width - 20, height: 30)
        self.delay_segment.selectedSegmentIndex = 0
        let atts3 = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let atts4 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        delay_segment.setTitleTextAttributes(atts3, for: .normal)
        delay_segment.setTitleTextAttributes(atts4, for: .selected)
        delay_segment.addTarget(self, action: #selector(handle_delay_segment(control:)), for: .valueChanged)
        self.dark_box.addSubview(delay_segment)

        self.sublabel2.frame = self.dark_box.bounds
        self.sublabel2.frame.size.height = 40
        self.sublabel2.frame.size.width -= 20
        self.sublabel2.frame.origin.x += 10
        self.sublabel2.frame.origin.y += 195
        self.sublabel2.toon_label_with(text: "No Delay", color: .white, alignment: 2, weight: 2, size: 15)
        self.sublabel2.alpha = 0.5
        self.dark_box.addSubview(self.sublabel2)

        
        
        
        
    }
    
    @objc func handle_reverb_segment(control: UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 0:
            self.settings_controller_link.origin_controller.set_reverb(value: 0)
            self.sublabel.text = "No Reverb"
        case 1:
            self.settings_controller_link.origin_controller.set_reverb(value: 0.1)
            self.sublabel.text = "Low Reverb"
        case 2:
            self.settings_controller_link.origin_controller.set_reverb(value: 0.25)
            self.sublabel.text = "Medium Reverb"
        case 3:
            self.settings_controller_link.origin_controller.set_reverb(value: 0.5)
            self.sublabel.text = "High Reverb"
        default:
            self.settings_controller_link.origin_controller.set_reverb(value: 0)
            self.sublabel.text = "No Reverb"
        }
    }
    
    @objc func handle_delay_segment(control: UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 0:
            self.settings_controller_link.origin_controller.set_delay(value: 0)
            self.sublabel2.text = "No Delay"
        case 1:
            self.settings_controller_link.origin_controller.set_delay(value: 1)
            self.sublabel2.text = "Low Delay"
        case 2:
            self.settings_controller_link.origin_controller.set_delay(value: 2)
            self.sublabel2.text = "Medium Delay"
        case 3:
            self.settings_controller_link.origin_controller.set_delay(value: 3)
            self.sublabel2.text = "High Delay"
        default:
            self.settings_controller_link.origin_controller.set_delay(value: 0)
            self.sublabel2.text = "No Delay"
        }
    }

}

// MARK: KEY SIGNATURE CELL
class KeySignatureCell: SettingsCell {
    
    var dark_box = UIView()
    var title_label = UILabel()
    var sublabel = UILabel()
    var key_segment = UISegmentedControl(items: ["A", "C", "D", "F"])
    
    var sublabel2 = UILabel()
    var scale_mode_segment = UISegmentedControl(items: ["1", "2", "3", "4"])
    
    func initialize_cell(height: CGFloat) {
        self.cell_height = height
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.dark_box.frame = self.bounds
        self.dark_box.frame.size.height -= 25
        self.dark_box.frame.size.width -= 20
        self.dark_box.frame.origin.x += 10
        self.dark_box.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.dark_box.layer.cornerRadius = 10
        self.contentView.addSubview(self.dark_box)
        
        self.title_label.frame = self.dark_box.bounds
        self.title_label.frame.size.height = 40
        self.title_label.frame.origin.x = 10
        self.title_label.toon_label_with(text: "Key Signature & Scale Mode:", color: .white, alignment: 0, weight: 2, size: 15)
        self.dark_box.addSubview(self.title_label)
        
        self.key_segment.frame = CGRect(x: 10, y: 75, width: self.dark_box.frame.size.width - 20, height: 30)
        self.key_segment.selectedSegmentIndex = 0
        let atts1 = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let atts2 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        key_segment.setTitleTextAttributes(atts1, for: .normal)
        key_segment.setTitleTextAttributes(atts2, for: .selected)
        key_segment.addTarget(self, action: #selector(handle_key_segment(control:)), for: .valueChanged)
        self.dark_box.addSubview(key_segment)

        
        self.sublabel.frame = self.dark_box.bounds
        self.sublabel.frame.size.height = 40
        self.sublabel.frame.size.width -= 20
        self.sublabel.frame.origin.x += 10
        self.sublabel.frame.origin.y += 110
        self.sublabel.toon_label_with(text: "A", color: .white, alignment: 2, weight: 2, size: 15)
        self.sublabel.alpha = 0.5
        self.dark_box.addSubview(self.sublabel)
        
        self.scale_mode_segment.frame = CGRect(x: 10, y: 160, width: self.dark_box.frame.size.width - 20, height: 30)
        self.scale_mode_segment.selectedSegmentIndex = 0
        let atts3 = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let atts4 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        scale_mode_segment.setTitleTextAttributes(atts3, for: .normal)
        scale_mode_segment.setTitleTextAttributes(atts4, for: .selected)
        scale_mode_segment.addTarget(self, action: #selector(handle_scale_mode_segment(control:)), for: .valueChanged)
        self.dark_box.addSubview(scale_mode_segment)

        self.sublabel2.frame = self.dark_box.bounds
        self.sublabel2.frame.size.height = 40
        self.sublabel2.frame.size.width -= 20
        self.sublabel2.frame.origin.x += 10
        self.sublabel2.frame.origin.y += 195
        self.sublabel2.toon_label_with(text: "Natural Minor", color: .white, alignment: 2, weight: 2, size: 15)
        self.sublabel2.alpha = 0.5
        self.dark_box.addSubview(self.sublabel2)

        
    }
    
    @objc func handle_key_segment(control: UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 0:
            self.settings_controller_link.origin_controller.master_key_signature = 0
            self.settings_controller_link.origin_controller.master_key_segment_mode = 1
            self.settings_controller_link.origin_controller.theory_assign_scale_mode()
            self.settings_controller_link.origin_controller.update_note_labels()
            self.sublabel.text = "A"
        case 1:
            self.settings_controller_link.origin_controller.master_key_signature = 3
            self.settings_controller_link.origin_controller.master_key_segment_mode = 2
            self.settings_controller_link.origin_controller.theory_assign_scale_mode()
            self.settings_controller_link.origin_controller.update_note_labels()
            self.sublabel.text = "C"
        case 2:
            self.settings_controller_link.origin_controller.master_key_signature = 5
            self.settings_controller_link.origin_controller.master_key_segment_mode = 3
            self.settings_controller_link.origin_controller.theory_assign_scale_mode()
            self.settings_controller_link.origin_controller.update_note_labels()
            self.sublabel.text = "D"
        case 3:
            self.settings_controller_link.origin_controller.master_key_signature = 8
            self.settings_controller_link.origin_controller.master_key_segment_mode = 4
            self.settings_controller_link.origin_controller.theory_assign_scale_mode()
            self.settings_controller_link.origin_controller.update_note_labels()
            self.sublabel.text = "F"
        default:
            self.settings_controller_link.origin_controller.master_key_signature = 0
            self.settings_controller_link.origin_controller.master_key_segment_mode = 1
            self.settings_controller_link.origin_controller.theory_assign_scale_mode()
            self.settings_controller_link.origin_controller.update_note_labels()
            self.sublabel.text = "A"
        }
    }

        
    @objc func handle_scale_mode_segment(control: UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 0:
            self.settings_controller_link.origin_controller.master_scale_mode = 1
            self.settings_controller_link.origin_controller.theory_assign_scale_mode()
            self.settings_controller_link.origin_controller.update_note_labels()
            self.sublabel2.text = "Natural Minor"
        case 1:
            self.settings_controller_link.origin_controller.master_scale_mode = 2
            self.settings_controller_link.origin_controller.theory_assign_scale_mode()
            self.settings_controller_link.origin_controller.update_note_labels()
            self.sublabel2.text = "Harmonic Minor"
        case 2:
            self.settings_controller_link.origin_controller.master_scale_mode = 3
            self.settings_controller_link.origin_controller.theory_assign_scale_mode()
            self.settings_controller_link.origin_controller.update_note_labels()
            self.sublabel2.text = "Melodic Minor"
        case 3:
            self.settings_controller_link.origin_controller.master_scale_mode = 4
            self.settings_controller_link.origin_controller.theory_assign_scale_mode()
            self.settings_controller_link.origin_controller.update_note_labels()
            self.sublabel2.text = "Major"
        default:
            self.settings_controller_link.origin_controller.master_scale_mode = 1
            self.settings_controller_link.origin_controller.theory_assign_scale_mode()
            self.settings_controller_link.origin_controller.update_note_labels()
            self.sublabel2.text = "No Delay"
        }
    }

}



// MARK: THEME CELL
class ThemeCell: SettingsCell {
    
    var dark_box = UIView()
    var title_label = UILabel()
    var sublabel = UILabel()
    var theme_segment = UISegmentedControl(items: ["1", "2", "3", "4"])
    
    func initialize_cell(height: CGFloat) {
        self.cell_height = height
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.dark_box.frame = self.bounds
        self.dark_box.frame.size.height -= 25
        self.dark_box.frame.size.width -= 20
        self.dark_box.frame.origin.x += 10
        self.dark_box.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.dark_box.layer.cornerRadius = 10
        self.contentView.addSubview(self.dark_box)
        
        self.title_label.frame = self.dark_box.bounds
        self.title_label.frame.size.height = 40
        self.title_label.frame.origin.x = 10
        self.title_label.toon_label_with(text: "App Theme:", color: .white, alignment: 0, weight: 2, size: 15)
        self.dark_box.addSubview(self.title_label)
        
        self.sublabel.frame = self.dark_box.bounds
        self.sublabel.frame.size.height = 40
        self.sublabel.frame.size.width -= 20
        self.sublabel.frame.origin.x += 10
        self.sublabel.frame.origin.y += 110
        self.sublabel.toon_label_with(text: "Default", color: .white, alignment: 2, weight: 2, size: 15)
        self.sublabel.alpha = 0.5
        self.dark_box.addSubview(self.sublabel)
        
        self.theme_segment.frame = CGRect(x: 10, y: 75, width: self.dark_box.frame.size.width - 20, height: 30)
        self.theme_segment.selectedSegmentIndex = 0
        let atts1 = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let atts2 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        theme_segment.setTitleTextAttributes(atts1, for: .normal)
        theme_segment.setTitleTextAttributes(atts2, for: .selected)
        theme_segment.addTarget(self, action: #selector(handle_theme_segment(control:)), for: .valueChanged)
        self.dark_box.addSubview(theme_segment)
        
    }
    
    @objc func handle_theme_segment(control: UISegmentedControl) {
        
        let defaults = UserDefaults.standard
        
        switch control.selectedSegmentIndex {
        case 0:
            self.settings_controller_link.origin_controller.master_theme = 1
            self.settings_controller_link.origin_controller.set_theme()
            self.sublabel.text = "Default"
            
            defaults.setValue(1, forKey: "THEME")
        case 1:
            self.settings_controller_link.origin_controller.master_theme = 2
            self.settings_controller_link.origin_controller.set_theme()
            self.sublabel.text = "Autumn"
            
            defaults.setValue(2, forKey: "THEME")
        case 2:
            self.settings_controller_link.origin_controller.master_theme = 3
            self.settings_controller_link.origin_controller.set_theme()
            self.sublabel.text = "Aquatic"
            
            defaults.setValue(3, forKey: "THEME")
        case 3:
            self.settings_controller_link.origin_controller.master_theme = 4
            self.settings_controller_link.origin_controller.set_theme()
            self.sublabel.text = "Spring"
            
            defaults.setValue(4, forKey: "THEME")

        default:
            self.settings_controller_link.origin_controller.master_theme = 1
            self.settings_controller_link.origin_controller.set_theme()
            self.sublabel.text = "Normal"
            
            defaults.setValue(1, forKey: "THEME")

        }
    }    
}
