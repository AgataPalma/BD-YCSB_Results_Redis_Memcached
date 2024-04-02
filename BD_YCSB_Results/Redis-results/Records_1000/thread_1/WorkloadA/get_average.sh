#!/bin/bash

# Array of input files
input_files=("outputRun_workloada_1.txt" "outputRun_workloada_2.txt" "outputRun_workloada_3.txt" "outputRun_workloada_4.txt" "outputRun_workloada_5.txt" "outputRun_workloada_6.txt")

# Function to calculate average
calculate_average() {
  local sum=0
  local count=0
  for val in "${@}"; do
    sum=$(awk "BEGIN {print $sum + $val; exit}")
    count=$((count + 1))
  done
  avg=$(awk "BEGIN {print $sum / $count; exit}")
  echo $avg
}

# Main script
main() {
  declare -A avg_op_latencies

  for file in "${input_files[@]}"; do
    echo "File: $file"
    # Extracting runtime and throughput
    runtime=$(awk '/OVERALL/ {print $3}' "$file")
    throughput=$(awk '/OVERALL/ {print $5}' "$file")
    echo "Average Runtime: $runtime ms"
    echo "Average Throughput: $throughput ops/sec"

    ops=("READ" "UPDATE" "INSERT" "DELETE")
    for op_type in "${ops[@]}"; do
      # Extracting operation latencies and calculate average
      latency=$(awk -v op_type="$op_type" '$1 == op_type {print $NF}' "$file" | awk '{sum+=$1} END {print sum/NR}')
      avg_op_latencies["$op_type"]+="$latency "
      echo "$op_type: $latency ms"
    done
  done

  echo "Overall Average Operation Latencies:"
  for op_type in "${ops[@]}"; do
    latencies=${avg_op_latencies["$op_type"]}
    avg_latency=$(calculate_average $latencies)
    echo "$op_type: $avg_latency ms"
  done
}

# Execute main function
main

