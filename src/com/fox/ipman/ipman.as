import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import flash.filters.DropShadowFilter;
import mx.utils.Delegate;
class com.fox.ipman.ipman{
	private var CharSheet:DistributedValue;
	static var dTargetOnly:DistributedValue;
	public static function main(swfRoot:MovieClip):Void{
		var s_app = new ipman(swfRoot);
		swfRoot.onLoad = function () {s_app.Load()};
		swfRoot.onUnload = function () {s_app.Unload()};
		swfRoot.OnModuleActivated = function(config:Archive) { s_app.Activate(config); };
		swfRoot.OnModuleDeactivated = function() { return s_app.Deactivate(); };
		
	}
	public function ipman() {
		CharSheet = DistributedValue.Create("character_sheet");
		dTargetOnly = DistributedValue.Create("IP_OnlyTargeted");
	}
	private function Load(){
		CharSheet.SignalChanged.Connect(AddMaxIP, this);
		dTargetOnly.SignalChanged.Connect(UpdateIPSettings, this);
		AddMaxIP(CharSheet);
		Hook();
	}
	private function Unload(){
		CharSheet.SignalChanged.Disconnect(AddMaxIP, this);
		dTargetOnly.SignalChanged.Disconnect(UpdateIPSettings, this);
	}
	private function Activate(config:Archive){
		dTargetOnly.SetValue(config.FindEntry("targetOnly",false));
	}
	private function Deactivate(){
		var archive:Archive = new Archive();
		archive.AddEntry("targetOnly", dTargetOnly.GetValue());
		return archive
	}
	private function UpdateIPSettings(){
		for (var i in _root.nametagcontroller.m_NametagArray){
			var tag = _root.nametagcontroller.m_NametagArray[i];
			tag.InitIP();
		}
	}
	private function AddMaxIP(dv:DistributedValue){
		if (dv.GetValue()){
			var skillList = _root.charactersheet2d.m_Window.m_Content.m_SkillsList;
			if (!skillList){
				setTimeout(Delegate.create(this, AddMaxIP), 100, dv);
				return
			}
			if (skillList._SlotStatChanged){
				return
			}
			skillList._SlotStatChanged = skillList.SlotStatChanged;
			skillList.SlotStatChanged = function(stat){
				this._SlotStatChanged(stat);
				if (stat == _global.Enums.Stat.e_ZebraFactor){
					var current = this.m_ItemPowerValue.text;
					var max = string(this.m_Character.GetStat(2000767));
					if (current != max){
						this.m_ItemPowerValue.text = current + " (" + max + ")";
						this.m_ItemPowerValue.autoSize = "right";
						this.m_ItemPowerValue.wordWrap = false;
					}
				}
			}
			skillList.m_Character.SignalStatChanged.Disconnect(skillList.SlotStatChanged, skillList);
			skillList.m_Character.SignalStatChanged.Connect(skillList.SlotStatChanged, skillList);
			skillList.SlotStatChanged(_global.Enums.Stat.e_ZebraFactor);
		}
	}
	public function Hook(){
		if (_global.com.Components.Nametag.prototype.InitIP){
			return
		}
		if (!_global.com.Components.Nametag.prototype.SetAsTarget || !_global.com.Components.Nametag.prototype.SlotDynelStatChanged){
			setTimeout(Delegate.create(this, Hook), 500);
			return
		}
		
	// create IP textfield
		var f = function(){
			if (this.IPPointer){
				this.IPPointer.removeTextField();
			}
			if (!this.m_IsNPC && (!ipman.dTargetOnly.GetValue() || this.m_IsTarget)){
				if (this.m_HealthBar){
					var Format:TextFormat = new TextFormat("_StandardFont", 8,0xFFFFFF,false);
					var field:TextField = this.m_HealthBar.createTextField("m_IPText", this.m_HealthBar.getNextHighestDepth(), this.m_HealthBar.m_Bar._x, this.m_HealthBar.m_Bar._height,20,20);
					field.autoSize = true;
					field.filters = [new DropShadowFilter(20, 45, 0, 1, 0, 0, 107, 2, false, false, false)];
					field.setNewTextFormat(Format);
					field.setTextFormat(Format);
					this.IPPointer = field;
				}else{
					var Format:TextFormat = new TextFormat("_StandardFont", 8,0xFFFFFF,false);
					var field:TextField = this.createTextField("m_IPText", this.getNextHighestDepth(), 0, this.m_Name.textHeight+1,20,20);
					field.autoSize = true;
					field.filters = [new DropShadowFilter(20, 45, 0, 1, 0, 0, 107, 2, false, false, false)];
					field.setNewTextFormat(Format);
					field.setTextFormat(Format);
					this.IPPointer = field;
				}
				var IP = this.m_Character.GetStat(2000607);
				var max = this.m_Character.GetStat(2000767);
				var text = "IP " + IP;
				if (IP < max){
					text += " (" + max + ")";
				}
				this.IPPointer.text = text;
			}
			
		}
		_global.com.Components.Nametag.prototype.InitIP = f;

	// Redraw when selecting player
		f = function(bool){
			arguments.callee.base.apply(this, arguments);
			this.InitIP();
		}
		f.base = _global.com.Components.Nametag.prototype.SetAsTarget;
		_global.com.Components.Nametag.prototype.SetAsTarget = f;
	
	// Redraw when setting target
		f = function(id){
			arguments.callee.base.apply(this, arguments);
			this.InitIP();
		}
		f.base = _global.com.Components.Nametag.prototype.SetDynelID;
		_global.com.Components.Nametag.prototype.SetDynelID = f;
	
	// Stats changed	
		f = function(statID){
			arguments.callee.base.apply(this, arguments);
			if (statID == 2000607 || statID == 2000767){
				var IP = this.m_Character.GetStat(2000607);
				var max = this.m_Character.GetStat(2000767);
				var text = "IP " + IP;
				if (IP < max){
					text += " (" + max + ")";
				}
				this.IPPointer.text = text;
			}
		}
		f.base = _global.com.Components.Nametag.prototype.SlotDynelStatChanged
		_global.com.Components.Nametag.prototype.SlotDynelStatChanged = f;
		
	// Update already created nametags
		for (var i in _root.nametagcontroller.m_NametagArray){
			var tag = _root.nametagcontroller.m_NametagArray[i];
			tag.InitIP();
		}
	}
}