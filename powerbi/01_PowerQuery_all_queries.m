// DataFolder
"C:\Users\admin\Downloads\plant_kpi_dataset\plant_kpi_dataset\data\" meta [IsParameterQuery = true, Type = "Text", IsParameterQueryRequired = true]

// ExtractTime
#datetime(2026, 10, 5, 6, 0, 0) meta [IsParameterQuery = true, Type = "DateTime", IsParameterQueryRequired = true]

// fnReadCsv
(fileName as text, columnTypes as list) as table =>
let
    // Reads one CSV from DataFolder, turns empty cells into null and applies types with en-US culture
    // (en-US matters on a Danish PC: otherwise "4.244" is read as 4244).
    Folder = if Text.EndsWith(DataFolder, "\") then DataFolder else DataFolder & "\",
    Source = Csv.Document(File.Contents(Folder & fileName), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    BlanksToNull = Table.ReplaceValue(Promoted, "", null, Replacer.ReplaceValue, Table.ColumnNames(Promoted)),
    Typed = Table.TransformColumnTypes(BlanksToNull, columnTypes, "en-US")
in
    Typed

// fnUtcToCopenhagen
(utc as datetime) as datetime =>
let
    // The historian logs in UTC. EU summer time runs from the last Sunday of March 01:00 UTC
    // to the last Sunday of October 01:00 UTC (UTC+2), otherwise UTC+1.
    y = Date.Year(utc),
    SummerStart = Date.StartOfWeek(#date(y, 3, 31), Day.Sunday) & #time(1, 0, 0),
    SummerEnd = Date.StartOfWeek(#date(y, 10, 31), Day.Sunday) & #time(1, 0, 0),
    OffsetHours = if utc >= SummerStart and utc < SummerEnd then 2 else 1
in
    utc + #duration(0, OffsetHours, 0, 0)

// raw_cmms_equipment
fnReadCsv("cmms_equipment.csv", {{"equipment_id", type text}, {"equipment_name", type text}, {"line_id", type text}, {"equipment_type", type text}, {"install_year", Int64.Type}, {"criticality", type text}})

// raw_cmms_work_orders
fnReadCsv("cmms_work_orders.csv", {{"work_order_id", type text}, {"equipment_id", type text}, {"wo_type", type text}, {"description", type text}, {"created_date", type date}, {"scheduled_date", type date}, {"completed_date", type date}, {"status", type text}, {"deferral_reason", type text}})

// raw_erp_clients
fnReadCsv("erp_clients.csv", {{"client_id", type text}, {"client_name", type text}, {"region", type text}})

// raw_erp_process_orders
fnReadCsv("erp_process_orders.csv", {{"process_order_id", type text}, {"sales_order_id", type text}, {"product_id", type text}, {"line_id", type text}, {"planned_qty_units", Int64.Type}, {"planned_start", type datetime}, {"planned_finish", type datetime}, {"po_status", type text}})

// raw_erp_products
fnReadCsv("erp_products.csv", {{"product_id", type text}, {"product_name", type text}, {"client_id", type text}, {"product_type", type text}, {"container", type text}, {"fill_volume_ml", type number}, {"target_fill_weight_g", type number}, {"approved_lines", type text}, {"std_cost_eur_per_unit", type number}})

// raw_erp_sales_orders
fnReadCsv("erp_sales_orders.csv", {{"sales_order_id", type text}, {"client_id", type text}, {"product_id", type text}, {"order_qty_units", Int64.Type}, {"order_date", type date}, {"requested_date", type date}, {"first_confirmed_date", type date}, {"current_due_date", type date}, {"due_date_changed_on", type date}, {"due_date_change_reason", type text}, {"order_status", type text}})

// raw_erp_shipments
fnReadCsv("erp_shipments.csv", {{"shipment_id", type text}, {"sales_order_id", type text}, {"batch_id", type text}, {"ship_date", type date}, {"qty_units", Int64.Type}})

// raw_erp_suppliers
fnReadCsv("erp_suppliers.csv", {{"supplier_id", type text}, {"supplier_name", type text}, {"supplies", type text}, {"country", type text}})

// raw_historian_line_hourly
fnReadCsv("historian_line_hourly.csv", {{"timestamp", type datetime}, {"line_id", type text}, {"speed_upm_avg", type number}, {"units_counted", Int64.Type}, {"fill_weight_mean_g", type number}, {"fill_weight_sd_g", type number}, {"room_temp_c", type number}, {"room_rh_pct", type number}, {"alarm_count", Int64.Type}})

// raw_kpi_targets
fnReadCsv("kpi_targets.csv", {{"month", type text}, {"scope", type text}, {"kpi", type text}, {"target", type number}, {"unit", type text}, {"direction", type text}, {"owner", type text}, {"definition_note", type text}})

// raw_mes_batch_steps
fnReadCsv("mes_batch_steps.csv", {{"batch_id", type text}, {"step", type text}, {"resource_id", type text}, {"step_start", type datetime}, {"step_end", type datetime}})

// raw_mes_batches
fnReadCsv("mes_batches.csv", {{"batch_id", type text}, {"process_order_id", type text}, {"product_id", type text}, {"line_id", type text}, {"batch_type", type text}, {"theoretical_units", Int64.Type}, {"units_filled", Int64.Type}, {"line_loss_units", Int64.Type}, {"units_rejected_inspection", Int64.Type}, {"qc_sample_units", Int64.Type}, {"units_good", Int64.Type}, {"reinspection_flag", type text}, {"fill_start", type datetime}, {"fill_end", type datetime}, {"shift_at_fill_start", type text}, {"crew_at_fill_start", type text}, {"batch_status", type text}})

// raw_mes_component_usage
fnReadCsv("mes_component_usage.csv", {{"batch_id", type text}, {"component_type", type text}, {"material_id", type text}, {"material_description", type text}, {"supplier_id", type text}, {"supplier_lot", type text}, {"qty_issued_units", Int64.Type}})

// raw_mes_downtime_events
fnReadCsv("mes_downtime_events.csv", {{"event_id", type text}, {"line_id", type text}, {"equipment_id", type text}, {"batch_id", type text}, {"phase", type text}, {"stop_type", type text}, {"reason_code", type text}, {"reason_text", type text}, {"start_time", type datetime}, {"end_time", type datetime}, {"duration_min", type number}, {"shift", type text}, {"work_order_id", type text}})

// raw_mes_inspection_rejects
fnReadCsv("mes_inspection_rejects.csv", {{"batch_id", type text}, {"defect_code", type text}, {"defect_description", type text}, {"units_rejected", Int64.Type}})

// raw_plan_line_schedule
fnReadCsv("plan_line_schedule.csv", {{"date", type date}, {"line_id", type text}, {"scheduled_hours", type number}, {"shift_pattern", type text}, {"non_working_reason", type text}})

// raw_qms_batch_release
fnReadCsv("qms_batch_release.csv", {{"batch_id", type text}, {"record_received_date", type date}, {"review_started_date", type date}, {"decision_date", type date}, {"disposition", type text}})

// raw_qms_deviations
fnReadCsv("qms_deviations.csv", {{"deviation_id", type text}, {"batch_id", type text}, {"line_id", type text}, {"opened_date", type date}, {"category", type text}, {"severity", type text}, {"status", type text}, {"closed_date", type date}, {"root_cause_category", type text}, {"capa_required", type text}})

// DimDate
let
    StartDate = #date(2025, 7, 1),
    EndDate = #date(2026, 12, 31),
    Dates = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1, 0, 0, 0)),
    AsList = Table.FromList(Dates, Splitter.SplitByNothing(), {"Date"}),
    AsTable = Table.TransformColumnTypes(AsList, {{"Date", type date}}),
    WeekStart = Table.AddColumn(AsTable, "WeekStart", each Date.StartOfWeek([Date], Day.Monday), type date),
    IsoYear = Table.AddColumn(WeekStart, "ISOYear", each Date.Year(Date.AddDays([WeekStart], 3)), Int64.Type),
    IsoWeek = Table.AddColumn(IsoYear, "ISOWeek", each Number.RoundDown((Date.DayOfYear(Date.AddDays([WeekStart], 3)) - 1) / 7) + 1, Int64.Type),
    WeekLabel = Table.AddColumn(IsoWeek, "WeekLabel", each Text.From([ISOYear]) & "-W" & Text.PadStart(Text.From([ISOWeek]), 2, "0") & " (" & Date.ToText([WeekStart], "dd MMM", "en-GB") & ")", type text),
    MonthStart = Table.AddColumn(WeekLabel, "MonthStart", each Date.StartOfMonth([Date]), type date),
    MonthLabel = Table.AddColumn(MonthStart, "Month", each Date.ToText([Date], "yyyy-MM"), type text),
    DayName = Table.AddColumn(MonthLabel, "DayName", each Date.DayOfWeekName([Date], "en-GB"), type text),
    InDataPeriod = Table.AddColumn(DayName, "InDataPeriod", each [Date] >= #date(2025, 10, 1) and [Date] <= #date(2026, 10, 1), type logical)
in
    InDataPeriod

// DimLine
#table(
    type table [line_id = text, line_name = text, format = text, rated_speed_upm = Int64.Type, install_year = Int64.Type],
    {
        {"FL-1", "FL-1 vials", "Vial", 200, 2019},
        {"FL-2", "FL-2 vials (older line)", "Vial", 120, 2011},
        {"FL-3", "FL-3 prefilled syringes", "Syringe", 150, 2021}
    })

// DimProduct
let
    Source = raw_erp_products,
    JoinClient = Table.NestedJoin(Source, {"client_id"}, raw_erp_clients, {"client_id"}, "cli", JoinKind.LeftOuter),
    ExpandClient = Table.ExpandTableColumn(JoinClient, "cli", {"client_name", "region"}),
    ClientName = Table.ReplaceValue(ExpandClient, null, "Internal (media fill)", Replacer.ReplaceValue, {"client_name"}),
    Format = Table.AddColumn(ClientName, "format", each if Text.StartsWith([container], "Syringe") then "Syringe" else "Vial", type text),
    Label = Table.AddColumn(Format, "product_label", each [product_id] & " " & [product_name], type text)
in
    Label

// DimEquipment
let
    Source = raw_cmms_equipment,
    Criticality = Table.ReplaceValue(Source, null, "n/a (line level)", Replacer.ReplaceValue, {"criticality"}),
    LineId = Table.ReplaceValue(Criticality, null, "Shared", Replacer.ReplaceValue, {"line_id"}),
    Label = Table.AddColumn(LineId, "equipment_label", each [equipment_id] & " " & [equipment_name], type text)
in
    Label

// FactDeviation
let
    // Fix: 3 deviations carry unpadded batch IDs (B3-214 instead of B3-0214).
    Source = raw_qms_deviations,
    FixBatchId = Table.TransformColumns(Source, {{"batch_id", each
        let Parts = Text.Split(_, "-")
        in if List.Count(Parts) = 2 and Text.Length(Parts{1}) < 4 then Parts{0} & "-" & Text.PadStart(Parts{1}, 4, "0") else _, type text}}),
    IsMajor = Table.AddColumn(FixBatchId, "is_major_critical", each [severity] = "Major" or [severity] = "Critical", type logical)
in
    IsMajor

// FactBatch
let
    // One row per batch (669 commercial + 6 media fills) with every fix and the KPI columns.
    Source = Table.Distinct(raw_mes_batches),
    FixPOKey = Table.TransformColumns(Source, {{"process_order_id", each
        let t = Text.Upper(Text.Trim(_))
        in if Text.StartsWith(t, "PO") and not Text.StartsWith(t, "PO-") then "PO-" & Text.Middle(t, 2) else t, type text}}),
    FillingSteps = Table.SelectRows(raw_mes_batch_steps, each [step] = "FILLING"),
    JoinFill = Table.NestedJoin(FixPOKey, {"batch_id"}, FillingSteps, {"batch_id"}, "fill", JoinKind.LeftOuter),
    ExpandFill = Table.ExpandTableColumn(JoinFill, "fill", {"step_end"}, {"filling_step_end"}),
    FillEnd = Table.AddColumn(ExpandFill, "fill_end_clean", each if [fill_end] = null then [filling_step_end] else [fill_end], type datetime),
    QcUnits = Table.AddColumn(FillEnd, "qc_sample_units_clean", each
        if [qc_sample_units] = null and [batch_type] = "Commercial"
        then [units_filled] - [units_rejected_inspection] - [units_good]
        else [qc_sample_units], Int64.Type),
    JoinRelease = Table.NestedJoin(QcUnits, {"batch_id"}, raw_qms_batch_release, {"batch_id"}, "rel", JoinKind.LeftOuter),
    ExpandRelease = Table.ExpandTableColumn(JoinRelease, "rel", {"record_received_date", "review_started_date", "decision_date", "disposition"}),
    DevPerBatch = Table.Group(FactDeviation, {"batch_id"}, {
        {"n_deviations", each Table.RowCount(_), Int64.Type},
        {"n_major_critical", each List.Count(List.Select([severity], (s) => s = "Major" or s = "Critical")), Int64.Type}}),
    JoinDev = Table.NestedJoin(ExpandRelease, {"batch_id"}, DevPerBatch, {"batch_id"}, "dev", JoinKind.LeftOuter),
    ExpandDev = Table.ExpandTableColumn(JoinDev, "dev", {"n_deviations", "n_major_critical"}),
    DevZero = Table.ReplaceValue(ExpandDev, null, 0, Replacer.ReplaceValue, {"n_deviations", "n_major_critical"}),
    JoinProduct = Table.NestedJoin(DevZero, {"product_id"}, raw_erp_products, {"product_id"}, "prod", JoinKind.LeftOuter),
    ExpandProduct = Table.ExpandTableColumn(JoinProduct, "prod", {"std_cost_eur_per_unit", "container"}),
    Closures = Table.SelectRows(raw_mes_component_usage, each [component_type] = "Closure"),
    JoinClosure = Table.NestedJoin(ExpandProduct, {"batch_id"}, Closures, {"batch_id"}, "clo", JoinKind.LeftOuter),
    ExpandClosure = Table.ExpandTableColumn(JoinClosure, "clo", {"supplier_id", "supplier_lot"}, {"closure_supplier_id", "closure_lot"}),
    IsCommercial = Table.AddColumn(ExpandClosure, "is_commercial", each [batch_type] = "Commercial", type logical),
    FillEndDate = Table.AddColumn(IsCommercial, "fill_end_date", each DateTime.Date([fill_end_clean]), type date),
    FillingMin = Table.AddColumn(FillEndDate, "filling_min", each Duration.TotalMinutes([fill_end_clean] - [fill_start]), type number),
    GoodReleased = Table.AddColumn(FillingMin, "units_good_released", each if [disposition] = "Rejected" then 0 else [units_good], Int64.Type),
    RejectedBatch = Table.AddColumn(GoodReleased, "rejected_batch_units", each if [disposition] = "Rejected" then [units_good] else 0, Int64.Type),
    ScrapUnits = Table.AddColumn(RejectedBatch, "scrap_units", each if [is_commercial] then [line_loss_units] + [units_rejected_inspection] + [rejected_batch_units] else null, Int64.Type),
    ScrapEur = Table.AddColumn(ScrapUnits, "scrap_eur", each if [is_commercial] then [scrap_units] * [std_cost_eur_per_unit] else null, type number),
    UnfilledBulk = Table.AddColumn(ScrapEur, "unfilled_bulk_units", each if [is_commercial] then [theoretical_units] - [units_filled] - [line_loss_units] else null, Int64.Type),
    RejectRate = Table.AddColumn(UnfilledBulk, "reject_rate", each if [is_commercial] then [units_rejected_inspection] / [units_filled] else null, type number),
    FirstPass = Table.AddColumn(RejectRate, "is_first_pass", each [is_commercial] and [reinspection_flag] <> "Y" and [n_major_critical] = 0, type logical),
    FirstPassStrict = Table.AddColumn(FirstPass, "is_first_pass_strict", each [is_commercial] and [reinspection_flag] <> "Y" and [n_deviations] = 0, type logical),
    ReleaseDateError = Table.AddColumn(FirstPassStrict, "release_date_error", each [decision_date] <> null and [review_started_date] <> null and [decision_date] < [review_started_date], type logical),
    QaQueue = Table.AddColumn(ReleaseDateError, "qa_queue_days", each if [review_started_date] = null then null else Duration.Days([review_started_date] - [record_received_date]), Int64.Type),
    QaReview = Table.AddColumn(QaQueue, "qa_review_days", each if [decision_date] = null or [release_date_error] then null else Duration.Days([decision_date] - [review_started_date]), Int64.Type),
    RemoveRaw = Table.RemoveColumns(QaReview, {"fill_end", "qc_sample_units", "filling_step_end", "container"}),
    Renamed = Table.RenameColumns(RemoveRaw, {{"fill_end_clean", "fill_end"}, {"qc_sample_units_clean", "qc_sample_units"}})
in
    Renamed

// FactStep
let
    // MES steps plus two derived waits; setups split into line clearance (same product as the
    // previous batch on the line) and product changeover. Times are elapsed hours.
    Steps = raw_mes_batch_steps,
    BatchInfo = Table.SelectColumns(FactBatch, {"batch_id", "product_id", "line_id"}),
    JoinBatch = Table.NestedJoin(Steps, {"batch_id"}, BatchInfo, {"batch_id"}, "b", JoinKind.LeftOuter),
    ExpandBatch = Table.ExpandTableColumn(JoinBatch, "b", {"product_id", "line_id"}),
    Setups = Table.Buffer(Table.Sort(Table.SelectRows(ExpandBatch, each [step] = "SETUP"), {{"line_id", Order.Ascending}, {"step_start", Order.Ascending}})),
    SetupLine = List.Buffer(Setups[line_id]),
    SetupProduct = List.Buffer(Setups[product_id]),
    SetupBatch = List.Buffer(Setups[batch_id]),
    SetupKind = List.Buffer(List.Transform(List.Positions(SetupBatch), (i) =>
        if i > 0 and SetupLine{i} = SetupLine{i - 1} and SetupProduct{i} = SetupProduct{i - 1}
        then "Setup: line clearance"
        else "Setup: product changeover")),
    SetupTypes = Table.FromColumns({SetupBatch, SetupKind}, type table [batch_id = text, setup_type = text]),
    JoinType = Table.NestedJoin(ExpandBatch, {"batch_id"}, SetupTypes, {"batch_id"}, "st", JoinKind.LeftOuter),
    ExpandType = Table.ExpandTableColumn(JoinType, "st", {"setup_type"}),
    StepName = Table.AddColumn(ExpandType, "step_name", each
        if [step] = "SETUP" then [setup_type]
        else if [step] = "FILLING" then "Filling"
        else if [step] = "INSPECTION" then "Visual inspection"
        else if [step] = "RE-INSPECTION" then "Re-inspection"
        else if [step] = "PACKAGING" then "Packaging"
        else [step], type text),
    StepHours = Table.AddColumn(StepName, "hours", each Duration.TotalHours([step_end] - [step_start]), type number),
    MainSteps = Table.SelectColumns(StepHours, {"batch_id", "step", "step_name", "resource_id", "step_start", "step_end", "hours"}),
    PerBatch = Table.Group(Steps, {"batch_id"}, {
        {"fill_end", each List.Max(Table.SelectRows(_, (r) => r[step] = "FILLING")[step_end]), type nullable datetime},
        {"insp_start", each List.Max(Table.SelectRows(_, (r) => r[step] = "INSPECTION")[step_start]), type nullable datetime},
        {"insp_end", each List.Max(Table.SelectRows(_, (r) => r[step] = "INSPECTION" or r[step] = "RE-INSPECTION")[step_end]), type nullable datetime},
        {"pack_start", each List.Max(Table.SelectRows(_, (r) => r[step] = "PACKAGING")[step_start]), type nullable datetime}}),
    MakeWait = (t as table, stepCode as text, stepLabel as text, fromCol as text, toCol as text) as table =>
        let
            Filtered = Table.SelectRows(t, each Record.Field(_, fromCol) <> null and Record.Field(_, toCol) <> null),
            Rows = Table.FromRecords(List.Transform(Table.ToRecords(Filtered), (r) => [
                batch_id = r[batch_id], step = stepCode, step_name = stepLabel, resource_id = null,
                step_start = Record.Field(r, fromCol), step_end = Record.Field(r, toCol),
                hours = Duration.TotalHours(Record.Field(r, toCol) - Record.Field(r, fromCol))]))
        in
            Rows,
    WaitRows = Table.Combine({
        MakeWait(PerBatch, "WAIT-INSPECTION", "Wait for inspection", "fill_end", "insp_start"),
        MakeWait(PerBatch, "WAIT-PACKAGING", "Wait for packaging", "insp_end", "pack_start")}),
    AllSteps = Table.Combine({MainSteps, WaitRows}),
    Typed = Table.TransformColumnTypes(AllSteps, {{"batch_id", type text}, {"step", type text}, {"step_name", type text}, {"resource_id", type text}, {"step_start", type datetime}, {"step_end", type datetime}, {"hours", type number}}),
    StepOrder = Table.AddColumn(Typed, "step_order", each
        if [step_name] = "Setup: line clearance" then 1
        else if [step_name] = "Setup: product changeover" then 2
        else if [step_name] = "Filling" then 3
        else if [step_name] = "Wait for inspection" then 4
        else if [step_name] = "Visual inspection" then 5
        else if [step_name] = "Re-inspection" then 6
        else if [step_name] = "Wait for packaging" then 7
        else 8, Int64.Type)
in
    StepOrder

// FactRejects
let
    // Fix: defect code STOP means a vial stopper on vials and a plunger stopper on syringes.
    Source = raw_mes_inspection_rejects,
    BatchProduct = Table.Distinct(Table.SelectColumns(raw_mes_batches, {"batch_id", "product_id"})),
    JoinBatch = Table.NestedJoin(Source, {"batch_id"}, BatchProduct, {"batch_id"}, "b", JoinKind.LeftOuter),
    ExpandBatch = Table.ExpandTableColumn(JoinBatch, "b", {"product_id"}),
    JoinProduct = Table.NestedJoin(ExpandBatch, {"product_id"}, raw_erp_products, {"product_id"}, "p", JoinKind.LeftOuter),
    ExpandProduct = Table.ExpandTableColumn(JoinProduct, "p", {"container"}),
    Format = Table.AddColumn(ExpandProduct, "format", each if Text.StartsWith([container], "Syringe") then "Syringe" else "Vial", type text),
    DefectKey = Table.AddColumn(Format, "defect_key", each if [defect_code] = "STOP" then (if [format] = "Syringe" then "STOP-S" else "STOP-V") else [defect_code], type text),
    Final = Table.RemoveColumns(DefectKey, {"product_id", "container"})
in
    Final

// FactDowntime
let
    // Fixes: swap 5 events whose end is before their start; null the minutes of 3 events that end
    // after their batch's phase ended; flag 35 double-logged events; code blank reasons as UNK.
    Source = raw_mes_downtime_events,
    EventNo = Table.AddColumn(Source, "event_no", each Number.From(Text.AfterDelimiter([event_id], "-")), Int64.Type),
    EndBeforeStart = Table.AddColumn(EventNo, "end_before_start", each [end_time] < [start_time], type logical),
    StartClean = Table.AddColumn(EndBeforeStart, "start_clean", each if [end_before_start] then [end_time] else [start_time], type datetime),
    EndClean = Table.AddColumn(StartClean, "end_clean", each if [end_before_start] then [start_time] else [end_time], type datetime),
    PhaseWindows = Table.AddColumn(Table.SelectRows(raw_mes_batch_steps, each [step] = "SETUP" or [step] = "FILLING"), "phase", each if [step] = "SETUP" then "Setup" else "Filling", type text),
    JoinWindow = Table.NestedJoin(EndClean, {"batch_id", "phase"}, PhaseWindows, {"batch_id", "phase"}, "win", JoinKind.LeftOuter),
    ExpandWindow = Table.ExpandTableColumn(JoinWindow, "win", {"step_end"}, {"phase_end"}),
    EndsAfterPhase = Table.AddColumn(ExpandWindow, "ends_after_phase", each [phase_end] <> null and [end_clean] > [phase_end], type logical),
    Sorted = Table.Buffer(Table.Sort(EndsAfterPhase, {{"equipment_id", Order.Ascending}, {"start_clean", Order.Ascending}, {"event_no", Order.Ascending}})),
    EqList = List.Buffer(Sorted[equipment_id]),
    StartList = List.Buffer(Sorted[start_clean]),
    NoList = List.Buffer(Sorted[event_no]),
    RowTotal = List.Count(EqList),
    DupFlags = List.Buffer(List.Transform({0 .. RowTotal - 1}, (i) =>
        (i > 0 and EqList{i - 1} = EqList{i} and Number.Abs(Duration.TotalMinutes(StartList{i} - StartList{i - 1})) <= 5 and NoList{i} > NoList{i - 1})
        or
        (i < RowTotal - 1 and EqList{i + 1} = EqList{i} and Number.Abs(Duration.TotalMinutes(StartList{i + 1} - StartList{i})) <= 5 and NoList{i} > NoList{i + 1}))),
    Indexed = Table.AddIndexColumn(Sorted, "row_index", 0, 1, Int64.Type),
    Duplicate = Table.AddColumn(Indexed, "is_duplicate", each DupFlags{[row_index]}, type logical),
    ReasonCode = Table.ReplaceValue(Duplicate, null, "UNK", Replacer.ReplaceValue, {"reason_code"}),
    ReasonText = Table.ReplaceValue(ReasonCode, null, "Not coded", Replacer.ReplaceValue, {"reason_text"}),
    CleanMinutes = Table.AddColumn(ReasonText, "duration_clean_min", each if [is_duplicate] or [ends_after_phase] then null else Duration.TotalMinutes([end_clean] - [start_clean]), type nullable number),
    ReasonGroup = Table.AddColumn(CleanMinutes, "reason_group", each
        if [stop_type] = "Planned" then "Planned intervention"
        else if Text.StartsWith([reason_code], "ORG") then "Waiting (organisational)"
        else if [reason_code] = "UNK" then "Not coded"
        else if [reason_code] = "OTH-99" then "Other"
        else "Equipment", type text),
    StartDate = Table.AddColumn(ReasonGroup, "start_date", each DateTime.Date([start_clean]), type date),
    Final = Table.RemoveColumns(StartDate, {"row_index", "phase_end"})
in
    Final

// Targets
let
    Source = raw_kpi_targets,
    MonthStart = Table.AddColumn(Source, "month_start", each Date.FromText([month] & "-01"), type date),
    TargetValue = Table.AddColumn(MonthStart, "target_value", each if [unit] = "%" then [target] / 100 else [target], type number)
in
    TargetValue

// FactSchedule
let
    // Throughput target per day = scheduled hours x weekly target / standard week hours
    // (120 h for 3 shifts, 80 h for 2 shifts), so holidays and shutdowns lower the target.
    // The batch data stops on 1 Oct 2026 (check V38), so later schedule days are cut off.
    LastFillDate = DateTime.Date(List.Max(FactBatch[fill_end])),
    Source = Table.SelectRows(raw_plan_line_schedule, each [date] <= LastFillDate),
    MonthStart = Table.AddColumn(Source, "month_start", each Date.StartOfMonth([date]), type date),
    ThroughputTargets = Table.SelectRows(Targets, each [kpi] = "Throughput"),
    JoinTarget = Table.NestedJoin(MonthStart, {"line_id", "month_start"}, ThroughputTargets, {"scope", "month_start"}, "t", JoinKind.LeftOuter),
    ExpandTarget = Table.ExpandTableColumn(JoinTarget, "t", {"target_value"}, {"weekly_target_units"}),
    StandardWeek = Table.AddColumn(ExpandTarget, "standard_week_hours", each if Text.StartsWith([shift_pattern], "2 shifts") then 80 else 120, Int64.Type),
    TargetUnits = Table.AddColumn(StandardWeek, "target_units", each if [weekly_target_units] = null then null else [scheduled_hours] * [weekly_target_units] / [standard_week_hours], type nullable number)
in
    TargetUnits

// FactShipment
let
    // Fix: 4 shipments have no batch_id. Each matches exactly one unshipped batch of the same
    // order with the same quantity, so the batch is filled in and flagged.
    Source = raw_erp_shipments,
    BatchOrder = Table.NestedJoin(Table.SelectColumns(FactBatch, {"batch_id", "process_order_id", "units_good"}), {"process_order_id"}, raw_erp_process_orders, {"process_order_id"}, "po", JoinKind.Inner),
    BatchOrderX = Table.ExpandTableColumn(BatchOrder, "po", {"sales_order_id"}),
    ShippedIds = List.Buffer(List.RemoveNulls(Source[batch_id])),
    Candidates = Table.Buffer(Table.SelectRows(BatchOrderX, each not List.Contains(ShippedIds, [batch_id]))),
    Recovered = Table.AddColumn(Source, "batch_id_clean", each
        if [batch_id] <> null then [batch_id]
        else
            let Match = Table.SelectRows(Candidates, (r) => r[sales_order_id] = [sales_order_id] and r[units_good] = [qty_units])
            in if Table.RowCount(Match) = 1 then Match{0}[batch_id] else null, type nullable text),
    Flag = Table.AddColumn(Recovered, "batch_id_recovered", each [batch_id] = null and [batch_id_clean] <> null, type logical),
    Final = Table.RenameColumns(Table.RemoveColumns(Flag, {"batch_id"}), {{"batch_id_clean", "batch_id"}})
in
    Final

// FactOrder
let
    // Committed date = first confirmed date, unless the client asked for the change (then the new date).
    Source = raw_erp_sales_orders,
    ShipAgg = Table.Group(FactShipment, {"sales_order_id"}, {
        {"last_ship_date", each List.Max([ship_date]), type nullable date},
        {"shipped_units", each List.Sum([qty_units]), type nullable number},
        {"shipments", each Table.RowCount(_), Int64.Type}}),
    JoinShip = Table.NestedJoin(Source, {"sales_order_id"}, ShipAgg, {"sales_order_id"}, "s", JoinKind.LeftOuter),
    ExpandShip = Table.ExpandTableColumn(JoinShip, "s", {"last_ship_date", "shipped_units", "shipments"}),
    CustomerChange = Table.AddColumn(ExpandShip, "customer_requested_change", each [due_date_change_reason] = "Customer request", type logical),
    Committed = Table.AddColumn(CustomerChange, "committed_date", each if [customer_requested_change] then [current_due_date] else [first_confirmed_date], type date),
    CustomerDate = Table.AddColumn(Committed, "customer_date", each if [customer_requested_change] then [current_due_date] else [requested_date], type date),
    Complete = Table.AddColumn(CustomerDate, "complete_date", each if [order_status] = "Shipped" then [last_ship_date] else null, type nullable date),
    Cutoff = DateTime.Date(ExtractTime),
    ScopeCommitted = Table.AddColumn(Complete, "in_scope_committed", each [committed_date] < Cutoff, type logical),
    OnTimeCommitted = Table.AddColumn(ScopeCommitted, "on_time_committed", each [complete_date] <> null and [complete_date] <= [committed_date], type logical),
    ScopeCurrent = Table.AddColumn(OnTimeCommitted, "in_scope_current", each [current_due_date] < Cutoff, type logical),
    OnTimeCurrent = Table.AddColumn(ScopeCurrent, "on_time_current", each [complete_date] <> null and [complete_date] <= [current_due_date], type logical),
    ScopeFirst = Table.AddColumn(OnTimeCurrent, "in_scope_first", each [first_confirmed_date] < Cutoff, type logical),
    OnTimeFirst = Table.AddColumn(ScopeFirst, "on_time_first", each [complete_date] <> null and [complete_date] <= [first_confirmed_date], type logical),
    ScopeCustomer = Table.AddColumn(OnTimeFirst, "in_scope_customer", each [customer_date] < Cutoff, type logical),
    OnTimeCustomer = Table.AddColumn(ScopeCustomer, "on_time_customer", each [complete_date] <> null and [complete_date] <= [customer_date], type logical),
    Rebaselined = Table.AddColumn(OnTimeCustomer, "changed_after_original_date", each [due_date_changed_on] <> null and [due_date_changed_on] > [first_confirmed_date], type logical),
    DaysLate = Table.AddColumn(Rebaselined, "days_late_committed", each if [in_scope_committed] then Duration.Days((if [complete_date] = null then Cutoff else [complete_date]) - [committed_date]) else null, Int64.Type)
in
    DaysLate

// FactWorkOrder
let
    Source = raw_cmms_work_orders,
    DaysLate = Table.AddColumn(Source, "days_late", each if [scheduled_date] = null or [completed_date] = null then null else Duration.Days([completed_date] - [scheduled_date]), Int64.Type),
    PmOnTime = Table.AddColumn(DaysLate, "pm_on_time", each if [wo_type] <> "PM" then null else ([completed_date] <> null and [days_late] <= 7), type nullable logical),
    PlanDate = Table.AddColumn(PmOnTime, "plan_date", each if [scheduled_date] = null then [created_date] else [scheduled_date], type date)
in
    PlanDate

// FactHistorian
let
    // Fixes: UTC to Copenhagen time; fill weight logged in mg on FL-1 from 12 May 2026 (values > 100).
    Source = raw_historian_line_hourly,
    LocalTime = Table.AddColumn(Source, "timestamp_local", each fnUtcToCopenhagen([timestamp]), type datetime),
    WasMg = Table.AddColumn(LocalTime, "fill_weight_was_mg", each [fill_weight_mean_g] <> null and [fill_weight_mean_g] > 100, type logical),
    FillWeight = Table.AddColumn(WasMg, "fill_weight_g", each if [fill_weight_was_mg] then [fill_weight_mean_g] / 1000 else [fill_weight_mean_g], type nullable number),
    FillWeightSd = Table.AddColumn(FillWeight, "fill_weight_sd_g_clean", each if [fill_weight_was_mg] then [fill_weight_sd_g] / 1000 else [fill_weight_sd_g], type nullable number),
    DateLocal = Table.AddColumn(FillWeightSd, "date_local", each DateTime.Date([timestamp_local]), type date),
    Running = Table.AddColumn(DateLocal, "is_running", each [units_counted] > 0, type logical),
    Final = Table.RemoveColumns(Running, {"fill_weight_mean_g", "fill_weight_sd_g"})
in
    Final

// KPI_List
#table(type table [kpi_order = Int64.Type, kpi = text], {
    {1, "Throughput (good units)"},
    {2, "Yield"},
    {3, "First-pass quality"},
    {4, "Scrap rate"},
    {5, "Unplanned downtime"},
    {6, "On-time delivery"}})

// KPI_Conflicts
#table(type table [conflict_order = Int64.Type, kpi = text, definition_a_chosen = text, definition_b = text, why_a = text], {
    {1, "Yield", "Released good units / theoretical units", "MES good units / filled units", "The bulk belongs to the client: losses before filling and rejected batches are real yield losses. The two give opposite answers against 96.5%, so leadership must confirm the target's basis."},
    {2, "First-pass quality", "No re-inspection and no major or critical deviation", "No re-inspection and no deviation of any severity", "Minor deviations (mostly documentation errors) do not change the batch's route or hold release. Only A fits the 92% target in a normal month (92-95% Oct-Feb)."},
    {3, "Scrap", "(Line loss + inspection rejects + rejected batches) / theoretical", "Every unit not released or sampled / theoretical (adds unfilled bulk)", "B adds about 1% of bulk that never became a unit and is already counted in yield. A matches the 2.0-2.5% targets."},
    {4, "Unplanned downtime", "Unplanned stop time during filling / filling time", "Unplanned stop time / scheduled time", "Only about a quarter of scheduled time is filling; the rest is setup or idle, where the filler cannot break down. B dilutes failures so every line looks fine."},
    {5, "Throughput", "Good units by fill-end week vs target pro-rated by scheduled hours", "Units released by QA per week vs the same target", "The weekly view is about what the lines made. B moves output into the week QA released it and swings with the QA queue (19 of 51 weeks differ by more than 25 points)."},
    {6, "On-time delivery", "Shipped complete by the committed date (first confirmed, or the client's new date)", "Shipped complete by the ERP current due date", "62 due dates were moved after the original date had passed (capacity, QA delay, no reason). Measuring against the moved date hides 61 late orders."}})

// KPI_Dictionary
#table(type table [kpi_order = Int64.Type, kpi = text, definition = text, formula = text, dax_measure = text, unit = text, source_tables = text, includes = text, excludes = text, date_attribution = text, target = text, owner = text], {
    {1, "Throughput", "Good units filled, against a target pro-rated for the hours each line was scheduled.", "SUM(units_good) / SUM(scheduled_hours x weekly target / standard week hours)", "[Good Units], [Throughput Target Units], [Throughput vs Target %]", "units per week; %", "mes_batches, plan_line_schedule, kpi_targets", "Commercial batches; holidays and shutdowns lower the target", "Media fills; the 5 duplicate MES rows", "Fill-end date of the batch", "FL-1 220,000; FL-2 180,000; FL-3 90,000 (2 shifts), 150,000 from Mar 2026", "Operations"},
    {2, "Yield", "Share of the theoretical units that became released, saleable units.", "SUM(units_good, 0 if QA rejected the batch) / SUM(theoretical_units)", "[Yield %]", "%", "mes_batches, qms_batch_release", "Commercial batches; batches still in QA review count with MES good units (provisional)", "Media fills; duplicate MES rows", "Fill-end date of the batch", "96.5% per line", "Operations"},
    {3, "First-pass quality", "Share of batches that needed no re-inspection and had no major or critical deviation.", "COUNT(batches with reinspection_flag = N and no Major/Critical deviation) / COUNT(batches)", "[FPQ %]", "% of batches", "mes_batches, qms_deviations", "Commercial batches; minor deviations do not fail a batch", "Media fills", "Fill-end date of the batch", "92% site", "Quality"},
    {4, "Scrap rate", "Units scrapped at the filler, at inspection and in QA-rejected batches, valued at standard cost.", "SUM(line_loss + rejects + good units of rejected batches) / SUM(theoretical_units); EUR = scrap units x std cost", "[Scrap %], [Scrap EUR]", "%; EUR", "mes_batches, mes_inspection_rejects, qms_batch_release, erp_products", "Commercial batches; rejected batches in full", "QC samples (planned use); unfilled bulk (shown in yield); media fills", "Fill-end date of the batch", "FL-1 2.0%; FL-2 2.5%; FL-3 2.0%", "Operations"},
    {5, "Unplanned downtime", "Unplanned stop time while filling, as a share of filling time.", "SUM(unplanned stop minutes, phase = Filling) / SUM(filling minutes)", "[Unplanned Downtime %]", "% of filling time", "mes_downtime_events, mes_batch_steps, mes_batches", "All unplanned reason codes incl. not coded; media fill batches (they use line time)", "Planned interventions (PLN-01); setup-phase waits (shown as setup time); 35 duplicate events; minutes of 3 events that end after their batch's filling ended", "Fill-end date of the batch the stop belongs to", "FL-1 9%; FL-2 10%; FL-3 9%", "Maintenance"},
    {6, "On-time delivery", "Share of orders due in the period that shipped complete on or before the committed date.", "COUNT(orders with all batches shipped <= committed date) / COUNT(orders with committed date in period and before the extract)", "[OTD %]", "% of orders", "erp_sales_orders, erp_shipments", "Orders due before 5 Oct 2026, shipped or not; short-shipped orders count as late", "Orders not yet due at the extract", "Committed date (first confirmed date, or the new date when the client asked for the change)", "95% Oct-Dec 2025, 96% from Jan 2026 (customer view vs requested date: 90%)", "Supply Chain (customer view: Customer Service)"}})

// RowCounts
let
    Expected = {
        {"cmms_equipment", raw_cmms_equipment, 21},
        {"cmms_work_orders", raw_cmms_work_orders, 273},
        {"erp_clients", raw_erp_clients, 5},
        {"erp_process_orders", raw_erp_process_orders, 669},
        {"erp_products", raw_erp_products, 11},
        {"erp_sales_orders", raw_erp_sales_orders, 488},
        {"erp_shipments", raw_erp_shipments, 637},
        {"erp_suppliers", raw_erp_suppliers, 6},
        {"historian_line_hourly", raw_historian_line_hourly, 26489},
        {"kpi_targets", raw_kpi_targets, 180},
        {"mes_batch_steps", raw_mes_batch_steps, 2721},
        {"mes_batches", raw_mes_batches, 680},
        {"mes_component_usage", raw_mes_component_usage, 1798},
        {"mes_downtime_events", raw_mes_downtime_events, 1859},
        {"mes_inspection_rejects", raw_mes_inspection_rejects, 4014},
        {"plan_line_schedule", raw_plan_line_schedule, 1107},
        {"qms_batch_release", raw_qms_batch_release, 669},
        {"qms_deviations", raw_qms_deviations, 223}},
    Rows = List.Transform(Expected, each {_{0}, _{2}, Table.RowCount(_{1})}),
    AsTable = #table(type table [table_name = text, expected_rows = Int64.Type, actual_rows = Int64.Type], Rows),
    Match = Table.AddColumn(AsTable, "matches_dictionary", each [expected_rows] = [actual_rows], type logical)
in
    Match

// Validation
let
    // One row per check: failing rows counted on the raw (or flagged) data, plus the decision taken.
    CountIf = (t as table, condition as function) as number => Table.RowCount(Table.SelectRows(t, condition)),
    ShiftOf = (t as datetime) as text => let h = Time.Hour(DateTime.Time(t)) in if h >= 6 and h < 14 then "Day" else if h >= 14 and h < 22 then "Evening" else "Night",
    RawBatches = raw_mes_batches,
    UniqueRaw = Table.Distinct(RawBatches),
    CommercialRaw = Table.SelectRows(UniqueRaw, each [batch_type] = "Commercial"),
    Commercial = Table.SelectRows(FactBatch, each [is_commercial]),
    CommercialIds = List.Buffer(Commercial[batch_id]),
    AllBatchIds = List.Buffer(FactBatch[batch_id]),
    PoIds = List.Buffer(raw_erp_process_orders[process_order_id]),
    Products = Table.Buffer(raw_erp_products),
    ReinspIds = List.Buffer(Table.SelectRows(raw_mes_batch_steps, each [step] = "RE-INSPECTION")[batch_id]),
    StepCounts = Table.Group(Table.SelectRows(raw_mes_batch_steps, each [step] <> "RE-INSPECTION"), {"batch_id"}, {{"n_steps", each List.Count(List.Distinct([step])), Int64.Type}}),
    CompleteStepIds = List.Buffer(Table.SelectRows(StepCounts, each [n_steps] = 4)[batch_id]),
    RejectSums = Table.Group(raw_mes_inspection_rejects, {"batch_id"}, {{"defect_units", each List.Sum([units_rejected]), type number}}),
    RejectJoin = Table.ExpandTableColumn(Table.NestedJoin(Commercial, {"batch_id"}, RejectSums, {"batch_id"}, "r", JoinKind.LeftOuter), "r", {"defect_units"}),
    CodeDescriptions = Table.Group(raw_mes_inspection_rejects, {"defect_code"}, {{"n_desc", each List.Count(List.Distinct([defect_description])), Int64.Type}}),
    Release = Table.Buffer(raw_qms_batch_release),
    ShipCheck = Table.ExpandTableColumn(Table.NestedJoin(FactShipment, {"batch_id"}, Release, {"batch_id"}, "rel", JoinKind.LeftOuter), "rel", {"decision_date", "disposition"}),
    DevRelease = Table.ExpandTableColumn(Table.NestedJoin(Table.SelectRows(FactDeviation, each [is_major_critical]), {"batch_id"}, Release, {"batch_id"}, "rel", JoinKind.Inner), "rel", {"decision_date", "disposition"}),
    PoPerOrder = Table.Group(raw_erp_process_orders, {"sales_order_id"}, {{"n_po", each Table.RowCount(_), Int64.Type}}),
    ShipPerOrder = Table.Group(FactShipment, {"sales_order_id"}, {{"n_ship", each Table.RowCount(_), Int64.Type}}),
    OrderShip = Table.ExpandTableColumn(Table.NestedJoin(Table.ExpandTableColumn(Table.NestedJoin(raw_erp_sales_orders, {"sales_order_id"}, PoPerOrder, {"sales_order_id"}, "p", JoinKind.LeftOuter), "p", {"n_po"}), {"sales_order_id"}, ShipPerOrder, {"sales_order_id"}, "s", JoinKind.LeftOuter), "s", {"n_ship"}),
    Hist = raw_historian_line_hourly,
    HistHours = Duration.TotalHours(List.Max(Hist[timestamp]) - List.Min(Hist[timestamp])) + 1,
    LastFillDate = DateTime.Date(List.Max(FactBatch[fill_end])),
    Checks = {
        {"V01", "mes_batches", "Uniqueness", "Exact duplicate batch rows", Table.RowCount(RawBatches) - Table.RowCount(UniqueRaw), "Fix", "Removed (Table.Distinct)", "Stop the MES extract writing the same batch twice"},
        {"V02", "mes_batches", "Uniqueness", "batch_id still repeated after removing exact duplicates", Table.RowCount(FactBatch) - List.Count(List.Distinct(FactBatch[batch_id])), "None needed", "", ""},
        {"V03", "mes_batches", "Consistency", "process_order_id not found in erp_process_orders (trailing space, lower case, missing hyphen)", CountIf(CommercialRaw, each not List.Contains(PoIds, [process_order_id])), "Fix", "Trim, upper-case, restore PO- prefix; all 669 then join 1:1", "Validate the PO key format at MES order download"},
        {"V04", "mes_batches", "Completeness", "fill_end blank", CountIf(UniqueRaw, each [fill_end] = null), "Fix", "Taken from the FILLING step end in mes_batch_steps", "Make fill_end mandatory when a batch is closed"},
        {"V05", "mes_batches", "Completeness", "qc_sample_units blank on a commercial batch", CountIf(CommercialRaw, each [qc_sample_units] = null), "Fix", "Derived from the unit balance: filled - rejected - good", "Make QC sample quantity mandatory"},
        {"V06", "mes_batches", "Completeness", "Media fills without inspection, QC or good-unit counts", CountIf(UniqueRaw, each [batch_type] = "Media fill"), "None needed", "Expected: media fills are inspected outside MES; quality KPIs exclude them, line-time KPIs keep them", ""},
        {"V07", "mes_batches", "Validity", "units_good <> units_filled - rejects - QC samples", CountIf(Commercial, each [units_good] <> [units_filled] - [units_rejected_inspection] - [qc_sample_units]), "None needed", "", ""},
        {"V08", "mes_batches", "Validity", "units_filled + line_loss_units > theoretical_units", CountIf(Commercial, each [units_filled] + [line_loss_units] > [theoretical_units]), "None needed", "", ""},
        {"V09", "mes_batches", "Validity", "Product filled on a line it is not approved for", CountIf(FactBatch, each not List.Contains(Text.Split(Table.SelectRows(Products, (p) => p[product_id] = [product_id]){0}[approved_lines], ";"), [line_id])), "None needed", "", ""},
        {"V10", "mes_batches", "Consistency", "reinspection_flag disagrees with a RE-INSPECTION step", CountIf(Commercial, each ([reinspection_flag] = "Y") <> List.Contains(ReinspIds, [batch_id])), "None needed", "", ""},
        {"V11", "mes_batches", "Validity", "Final reject rate above the 2.5% alert limit without re-inspection", CountIf(Commercial, each [reject_rate] > 0.025 and [reinspection_flag] <> "Y"), "None needed", "Note: final counts are after re-inspection, so they understate first-pass rejects", "Store the first-pass reject count before re-inspection"},
        {"V12", "mes_batch_steps", "Completeness", "Commercial batch missing SETUP, FILLING, INSPECTION or PACKAGING", CountIf(Commercial, each not List.Contains(CompleteStepIds, [batch_id])), "None needed", "", ""},
        {"V13", "mes_batch_steps", "Validity", "step_end before step_start", CountIf(raw_mes_batch_steps, each [step_end] < [step_start]), "None needed", "Steps pause over weekends (elapsed time), so the dashboard uses medians", ""},
        {"V14", "mes_downtime_events", "Validity", "end_time before start_time", CountIf(FactDowntime, each [end_before_start]), "Fix", "Start and end swapped; all 5 then sit inside their batch phase and the shift label fits", "Block saving a stop that ends before it starts"},
        {"V15", "mes_downtime_events", "Validity", "Stop ends after its batch's setup or filling step ended (82-137 h)", CountIf(FactDowntime, each [ends_after_phase]), "Exclude", "Minutes set to blank, stop still counted; historian shows the line running", "Validate stop end against the running batch"},
        {"V16", "mes_downtime_events", "Uniqueness", "Double-logged stop: same equipment, start within 5 min of a lower event ID", CountIf(FactDowntime, each [is_duplicate]), "Exclude", "Dropped from minutes and counts (all are EV-501825 to EV-501859)", "Prevent two terminals logging the same stop"},
        {"V17", "mes_downtime_events", "Completeness", "reason_code blank", CountIf(raw_mes_downtime_events, each [reason_code] = null), "Flag", "Coded UNK / Not coded and shown as its own cause", "Make the reason code mandatory before a stop can be closed"},
        {"V18", "mes_downtime_events", "Consistency", "Shift label does not match start_time", CountIf(raw_mes_downtime_events, each ShiftOf([start_time]) <> [shift]), "None needed", "Knock-on of V14: EV-501627 had start and end swapped; after the swap the label matches", ""},
        {"V19", "mes_downtime_events", "Consistency", "Stop references a batch not in mes_batches", CountIf(FactDowntime, each not List.Contains(AllBatchIds, [batch_id])), "None needed", "", ""},
        {"V20", "mes_inspection_rejects", "Consistency", "Sum of defect rows <> units_rejected_inspection", CountIf(RejectJoin, each [defect_units] <> [units_rejected_inspection]), "None needed", "", ""},
        {"V21", "mes_inspection_rejects", "Consistency", "Defect code with more than one description", CountIf(CodeDescriptions, each [n_desc] > 1), "Fix", "STOP split into STOP-V (vial stopper) and STOP-S (plunger stopper)", "Use separate codes per component"},
        {"V22", "erp_shipments", "Completeness", "batch_id blank", CountIf(raw_erp_shipments, each [batch_id] = null), "Fix", "Recovered: the only unshipped batch of the order with the same quantity", "Make batch mandatory on goods issue"},
        {"V23", "erp_shipments", "Consistency", "Shipped batch not released, or shipped before the release decision", CountIf(ShipCheck, each [disposition] <> "Released" or [ship_date] < [decision_date]), "None needed", "", ""},
        {"V24", "erp_sales_orders", "Completeness", "Due date changed without a reason", CountIf(raw_erp_sales_orders, each [due_date_changed_on] <> null and [due_date_change_reason] = null), "Flag", "Treated as not requested by the client: OTD uses the first confirmed date", "Make a reason mandatory for every due-date change"},
        {"V25", "erp_sales_orders", "Validity", "Requested date before order date", CountIf(raw_erp_sales_orders, each [requested_date] < [order_date]), "Flag", "Kept; affects the customer view only", "Check requested dates at order entry"},
        {"V26", "erp_sales_orders", "Consistency", "Due date moved after the original confirmed date had passed", CountIf(raw_erp_sales_orders, each [due_date_changed_on] <> null and [due_date_changed_on] > [first_confirmed_date]), "Flag", "OTD measured on the committed date, not the ERP current due date", "Keep the original promise date as its own field"},
        {"V27", "erp_sales_orders", "Consistency", "Order status disagrees with shipments (Shipped but batches missing, or the reverse)", CountIf(OrderShip, each ([order_status] = "Shipped") <> ([n_ship] = [n_po])), "None needed", "", ""},
        {"V28", "qms_batch_release", "Validity", "Decision date before review start (and before record receipt)", CountIf(raw_qms_batch_release, each [decision_date] <> null and [review_started_date] <> null and [decision_date] < [review_started_date]), "Flag", "Disposition kept; excluded from QA review time", "Correct the dates (likely a month typo)"},
        {"V29", "qms_deviations", "Consistency", "batch_id not found in mes_batches", CountIf(raw_qms_deviations, each not List.Contains(AllBatchIds, [batch_id])), "Fix", "Zero-padded (B3-214 to B3-0214); all then match", "Pick the batch from a list in QMS"},
        {"V30", "qms_deviations", "Consistency", "Released with a major/critical deviation still open at the decision", CountIf(DevRelease, each [disposition] = "Released" and ([closed_date] = null or [closed_date] > [decision_date])), "None needed", "", ""},
        {"V31", "qms_deviations", "Completeness", "Open deviations without closure date or root cause", CountIf(raw_qms_deviations, each [status] = "Open"), "None needed", "Expected for open records", ""},
        {"V32", "cmms_work_orders", "Consistency", "Status Completed although finished after the scheduled date", CountIf(raw_cmms_work_orders, each [status] = "Completed" and [scheduled_date] <> null and [completed_date] > [scheduled_date]), "Flag", "PM compliance computed from dates (done within 7 days), not from status", "Define on-time in CMMS and derive the status from it"},
        {"V33", "cmms_work_orders", "Completeness", "PM cancelled, never completed", CountIf(raw_cmms_work_orders, each [status] = "Cancelled"), "None needed", "All three are FL-2-STP (see issue 1)", ""},
        {"V34", "cmms_equipment", "Completeness", "Criticality blank", CountIf(raw_cmms_equipment, each [criticality] = null), "None needed", "The three FL-x-LINE rows are not real equipment", ""},
        {"V35", "historian_line_hourly", "Consistency", "Timestamps in UTC, not site local time (every row)", Table.RowCount(Hist), "Fix", "Converted to Copenhagen time with summer-time rules; then filler counts match MES within 0.5%", "Document the time zone of each extract"},
        {"V36", "historian_line_hourly", "Validity", "Fill weight logged in mg instead of g (FL-1 from 12 May 2026)", CountIf(Hist, each [fill_weight_mean_g] <> null and [fill_weight_mean_g] > 100), "Fix", "Divided by 1,000", "Fix the tag's engineering unit"},
        {"V37", "historian_line_hourly", "Completeness", "Missing hourly rows (FL-3, 9-12 Feb 2026)", 3 * HistHours - Table.RowCount(Hist), "Flag", "Two batches (B3-0188, B3-0189) have no historian data", "Backfill the FL-3 gap"},
        {"V38", "plan_line_schedule", "Completeness", "Scheduled line-days after the last filling in the data (data ends 1 Oct 2026)", CountIf(raw_plan_line_schedule, each [date] > LastFillDate and [scheduled_hours] > 0), "Exclude", "Schedule cut at 1 Oct 2026 so targets only cover days with data; last full week is 21-27 Sep 2026", "Extract up to the extract time"},
        {"V39", "kpi_targets", "Completeness", "Target rows without a definition", CountIf(raw_kpi_targets, each [definition_note] = null), "Flag", "Definitions decided in the KPI dictionary", "Agree definitions with KPI owners"}
    },
    Result = #table(type table [check_id = text, table_name = text, dimension = text, check = text, failing_rows = Int64.Type, decision = text, action = text, ask_data_engineering = text], Checks),
    Status = Table.AddColumn(Result, "status", each if [failing_rows] = 0 then "Pass" else if [decision] = "None needed" then "Info" else [decision], type text)
in
    Status
