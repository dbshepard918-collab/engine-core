extends SceneTree

var failures := 0
func _init() -> void:
    test_skill_purchase_dependencies()
    test_quest_progression()
    test_dialogue_choice_filtering()
    quit(failures)

func assert_true(v: bool, msg: String) -> void:
    if not v:
        failures += 1
        print("FAIL: " + msg)
    else:
        print("PASS: " + msg)

func test_skill_purchase_dependencies() -> void:
    var tree_def := SkillTreeDefinition.new()
    var a := SkillTreeNodeDefinition.new(); a.id = "a"; a.max_rank = 1; a.cost_per_rank = 1
    var b := SkillTreeNodeDefinition.new(); b.id = "b"; b.required_node_ids = ["a"]; b.max_rank = 1; b.cost_per_rank = 1
    tree_def.nodes = [a, b]
    var tree := PlayerSkillTree.new(); tree.tree_definition = tree_def; tree.available_points = 2; get_root().add_child(tree)
    assert_true(not tree.can_purchase("b"), "dependent node cannot be bought first")
    assert_true(tree.purchase("a"), "root node purchased")
    assert_true(tree.can_purchase("b"), "dependent node unlocks after prerequisite")

func test_quest_progression() -> void:
    var step := QuestStepDefinition.new(); step.id = "kill"; step.step_type = QuestStepDefinition.StepType.KILL_ENEMY; step.target_id = "enemy_test"; step.required_count = 2
    var q := QuestDefinition.new(); q.id = "q_test"; q.title = "Test Quest"; q.steps = [step]
    var qm := QuestManager.new(); qm.quest_database = [q]; get_root().add_child(qm); qm._ready()
    assert_true(qm.start_quest("q_test"), "quest starts")
    qm.add_progress(QuestStepDefinition.StepType.KILL_ENEMY, "enemy_test", 1)
    assert_true(qm.active_quests.has("q_test"), "quest remains active after partial progress")
    qm.add_progress(QuestStepDefinition.StepType.KILL_ENEMY, "enemy_test", 1)
    assert_true(qm.completed_quests.has("q_test"), "quest completes after required progress")

func test_dialogue_choice_filtering() -> void:
    var choice := DialogueChoice.new(); choice.text = "Quest choice"; choice.required_quest_id = "q_active"
    var node := DialogueNodeDefinition.new(); node.choices = [choice]
    var qm := QuestManager.new(); get_root().add_child(qm)
    var dm := DialogueManager.new(); dm.quest_manager = qm; get_root().add_child(dm)
    assert_true(dm.get_available_choices(node).is_empty(), "choice hidden without active quest")
    qm.active_quests["q_active"] = QuestInstance.new()
    assert_true(dm.get_available_choices(node).size() == 1, "choice visible with active quest")
