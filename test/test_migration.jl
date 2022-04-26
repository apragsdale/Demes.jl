@testset "Migration" begin
    # test bad migration start time
    @test_throws Demes.MigrationError Demes.validateMigrationStartTime(
        Dict(),
        "A",
        "B",
        Dict(),
    )
    @test_throws Demes.MigrationError Demes.validateMigrationStartTime(
        Dict(),
        "A",
        "B",
        Dict("A" => [2, 1]),
    )
    @test_throws Demes.MigrationError Demes.validateMigrationStartTime(
        Dict(),
        "A",
        "B",
        Dict("B" => [2, 1]),
    )
    @test_throws Demes.MigrationError Demes.validateMigrationStartTime(
        Dict("start_time" => 15),
        "A",
        "B",
        Dict("A" => [10, 0], "B" => [20, 0]),
    )
    @test_throws Demes.MigrationError Demes.validateMigrationStartTime(
        Dict("start_time" => 15),
        "A",
        "B",
        Dict("A" => [20, 0], "B" => [10, 0]),
    )
    @test Demes.validateMigrationStartTime(
        Dict(),
        "A",
        "B",
        Dict("A" => [10, 0], "B" => [10, 0]),
    ) == 10
    @test Demes.validateMigrationStartTime(
        Dict(),
        "A",
        "B",
        Dict("A" => [5, 0], "B" => [10, 2]),
    ) == 5
    @test Demes.validateMigrationStartTime(
        Dict(),
        "A",
        "B",
        Dict("A" => [5, 0], "B" => [1, 0]),
    ) == 1
    # test bad migration end time
    @test_throws Demes.MigrationError Demes.validateMigrationEndTime(
        Dict(),
        "A",
        "B",
        Dict(),
    )
    @test_throws Demes.MigrationError Demes.validateMigrationEndTime(
        Dict(),
        "A",
        "B",
        Dict("A" => [2, 1]),
    )
    @test_throws Demes.MigrationError Demes.validateMigrationEndTime(
        Dict(),
        "A",
        "B",
        Dict("B" => [2, 1]),
    )
    @test_throws Demes.MigrationError Demes.validateMigrationEndTime(
        Dict("end_time" => 2),
        "A",
        "B",
        Dict("A" => [10, 5], "B" => [20, 0]),
    )
    @test_throws Demes.MigrationError Demes.validateMigrationEndTime(
        Dict("end_time" => 2),
        "A",
        "B",
        Dict("A" => [20, 0], "B" => [10, 5]),
    )
    @test Demes.validateMigrationEndTime(
        Dict(),
        "A",
        "B",
        Dict("A" => [10, 0], "B" => [10, 0]),
    ) == 0
    @test Demes.validateMigrationEndTime(
        Dict(),
        "A",
        "B",
        Dict("A" => [10, 0], "B" => [10, 2]),
    ) == 2
    @test Demes.validateMigrationEndTime(
        Dict(),
        "A",
        "B",
        Dict("A" => [10, 3], "B" => [10, 2]),
    ) == 3
end
