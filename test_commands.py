#!/usr/bin/env python3
"""
RADICAL SEA BUNNY - Command Test Suite
Version: 2.0.0
Description: Comprehensive testing of all RADICAL SEA BUNNY commands and features
"""

import os
import sys
import time
import json
import socket
import subprocess
import threading
import uuid
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass, field
from datetime import datetime

# Add parent directory to path for importing RADICAL SEA BUNNY modules
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Try to import RADICAL SEA BUNNY modules
try:
    from radical_sea_bunny import (
        ConfigManager, DatabaseManager, CommandHandler, SSHManager,
        TrafficGeneratorEngine, NiktoScanner, SocialEngineeringTools,
        NetworkTools, Colors, VERSION, NAME
    )
    MODULES_AVAILABLE = True
except ImportError as e:
    MODULES_AVAILABLE = False
    print(f"⚠️ Could not import RADICAL SEA BUNNY modules: {e}")
    print("   Running in standalone test mode")

# Color codes for terminal
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BOLD = '\033[1m'
    RESET = '\033[0m'

@dataclass
class TestResult:
    name: str
    category: str
    passed: bool
    message: str
    duration: float = 0.0
    details: Dict = field(default_factory=dict)

@dataclass
class CommandTest:
    name: str
    category: str
    command: str
    expected_success: bool = True
    expected_output_contains: Optional[List[str]] = None
    timeout: int = 30
    skip_if_no_module: bool = True

class CommandTester:
    def __init__(self):
        self.results: List[TestResult] = []
        self.start_time = datetime.now()
        
        # Initialize RADICAL SEA BUNNY components if available
        if MODULES_AVAILABLE:
            try:
                self.config = ConfigManager()
                self.db = DatabaseManager()
                self.ssh = SSHManager(self.db) if MODULES_AVAILABLE else None
                self.traffic = TrafficGeneratorEngine(self.db) if MODULES_AVAILABLE else None
                self.nikto = NiktoScanner(self.db) if MODULES_AVAILABLE else None
                self.handler = CommandHandler(self.db, self.ssh, self.traffic, self.nikto)
                self.tools = NetworkTools()
                print(f"{Colors.GREEN}✅ RADICAL SEA BUNNY modules loaded{Colors.RESET}")
            except Exception as e:
                print(f"{Colors.YELLOW}⚠️ Could not initialize modules: {e}{Colors.RESET}")
    
    def print_header(self):
        """Print test header"""
        print(f"\n{Colors.BOLD}{Colors.CYAN}╔═══════════════════════════════════════════════════════════════════╗{Colors.RESET}")
        print(f"{Colors.BOLD}{Colors.CYAN}║     🐇 RADICAL SEA BUNNY v2.0.0 - Command Test Suite           ║{Colors.RESET}")
        print(f"{Colors.BOLD}{Colors.CYAN}╚═══════════════════════════════════════════════════════════════════╝{Colors.RESET}")
        print(f"\n{Colors.BOLD}📋 Test Information:{Colors.RESET}")
        print(f"  Start Time: {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"  Modules Available: {Colors.GREEN}Yes{Colors.RESET if MODULES_AVAILABLE else Colors.RED}No{Colors.RESET}")
        print("")
    
    def print_result(self, result: TestResult):
        """Print a single test result"""
        status = f"{Colors.GREEN}✅ PASS{Colors.RESET}" if result.passed else f"{Colors.RED}❌ FAIL{Colors.RESET}"
        print(f"  {status} {result.name} ({result.duration:.2f}s)")
        if not result.passed:
            print(f"    {Colors.YELLOW}→ {result.message}{Colors.RESET}")
        if result.details:
            for key, value in result.details.items():
                if value:
                    print(f"    {key}: {value}")
    
    def print_summary(self):
        """Print test summary"""
        total = len(self.results)
        passed = sum(1 for r in self.results if r.passed)
        failed = total - passed
        duration = (datetime.now() - self.start_time).total_seconds()
        
        print(f"\n{Colors.BOLD}📊 Test Summary:{Colors.RESET}")
        print(f"  Total Tests: {total}")
        print(f"  {Colors.GREEN}✅ Passed: {passed}{Colors.RESET}")
        print(f"  {Colors.RED}❌ Failed: {failed}{Colors.RESET}")
        print(f"  Duration: {duration:.2f}s")
        
        if failed == 0:
            print(f"\n{Colors.GREEN}{Colors.BOLD}🎉 All tests passed! RADICAL SEA BUNNY is ready!{Colors.RESET}")
        else:
            print(f"\n{Colors.RED}{Colors.BOLD}⚠️ Some tests failed. Please check the output above.{Colors.RESET}")
    
    def run_command_test(self, test: CommandTest) -> TestResult:
        """Run a single command test"""
        start_time = time.time()
        
        try:
            # Execute command through handler if available
            if MODULES_AVAILABLE and hasattr(self, 'handler'):
                result = self.handler.execute(test.command, 'test', 'test_user')
                duration = time.time() - start_time
                
                passed = result.get('success', False) == test.expected_success
                message = result.get('output', '')[:200]
                
                if test.expected_output_contains and passed:
                    output = result.get('output', '')
                    for expected in test.expected_output_contains:
                        if expected not in output:
                            passed = False
                            message = f"Expected '{expected}' not found in output"
                            break
                
                return TestResult(
                    name=test.name,
                    category=test.category,
                    passed=passed,
                    message=message if not passed else "Command executed successfully",
                    duration=duration,
                    details={"output": result.get('output', '')[:100]}
                )
            else:
                # Fallback to subprocess
                result = subprocess.run(
                    test.command,
                    shell=True,
                    capture_output=True,
                    text=True,
                    timeout=test.timeout
                )
                duration = time.time() - start_time
                
                passed = result.returncode == 0 if test.expected_success else True
                message = result.stdout[:200] if result.stdout else result.stderr[:200]
                
                if test.expected_output_contains and passed:
                    output = result.stdout + result.stderr
                    for expected in test.expected_output_contains:
                        if expected not in output:
                            passed = False
                            message = f"Expected '{expected}' not found in output"
                            break
                
                return TestResult(
                    name=test.name,
                    category=test.category,
                    passed=passed,
                    message=message if not passed else "Command executed successfully",
                    duration=duration,
                    details={"output": result.stdout[:100], "error": result.stderr[:100]}
                )
                
        except subprocess.TimeoutExpired:
            return TestResult(
                name=test.name,
                category=test.category,
                passed=False,
                message=f"Command timed out after {test.timeout}s",
                duration=time.time() - start_time
            )
        except Exception as e:
            return TestResult(
                name=test.name,
                category=test.category,
                passed=False,
                message=f"Error: {str(e)}",
                duration=time.time() - start_time
            )
    
    def get_command_tests(self) -> List[CommandTest]:
        """Define all command tests"""
        tests = []
        
        # Network Commands
        tests.append(CommandTest(
            name="Ping Localhost",
            category="Network",
            command="ping 127.0.0.1 -c 2" if os.name != 'nt' else "ping 127.0.0.1 -n 2",
            expected_output_contains=["127.0.0.1", "time"]
        ))
        
        tests.append(CommandTest(
            name="Ping Google DNS",
            category="Network",
            command="ping 8.8.8.8 -c 2" if os.name != 'nt' else "ping 8.8.8.8 -n 2",
            expected_output_contains=["8.8.8.8"]
        ))
        
        # Nmap Commands (if available)
        if shutil.which('nmap'):
            tests.append(CommandTest(
                name="Nmap Quick Scan",
                category="Network",
                command="nmap -T4 -F 127.0.0.1",
                expected_output_contains=["Nmap", "scan"]
            ))
        
        # Curl Commands
        tests.append(CommandTest(
            name="Curl Google",
            category="Network",
            command="curl -s -I https://google.com | head -1" if os.name != 'nt' else "curl -s -I https://google.com",
            expected_output_contains=["HTTP", "200"]
        ))
        
        # DNS Commands
        tests.append(CommandTest(
            name="DNS Resolution",
            category="Network",
            command="dig google.com +short" if shutil.which('dig') else "nslookup google.com",
            expected_output_contains=["google.com", "8.8.8.8"]
        ))
        
        # System Commands
        tests.append(CommandTest(
            name="System Info",
            category="System",
            command="ps aux | head -5" if os.name != 'nt' else "tasklist | findstr /i python",
            expected_output_contains=[]
        ))
        
        # Python Module Tests
        tests.append(CommandTest(
            name="Python Version Check",
            category="System",
            command="python --version",
            expected_output_contains=["Python"]
        ))
        
        tests.append(CommandTest(
            name="Pip Version Check",
            category="System",
            command="pip --version",
            expected_output_contains=["pip"]
        ))
        
        # SSH Connectivity (if available)
        tests.append(CommandTest(
            name="SSH Client Check",
            category="Security",
            command="ssh -V 2>&1",
            expected_output_contains=["OpenSSH"]
        ))
        
        # File Operations
        tests.append(CommandTest(
            name="Directory Creation",
            category="System",
            command="mkdir -p test_dir && echo 'created'",
            expected_output_contains=["created"]
        ))
        
        tests.append(CommandTest(
            name="File Operations",
            category="System",
            command="echo 'test' > test_file.txt && cat test_file.txt",
            expected_output_contains=["test"]
        ))
        
        # Cleanup
        tests.append(CommandTest(
            name="Cleanup Test Files",
            category="System",
            command="rm -rf test_dir test_file.txt 2>/dev/null || rm -rf test_dir test_file.txt 2>nul",
            expected_success=True
        ))
        
        # RADICAL SEA BUNNY Specific Tests (if modules available)
        if MODULES_AVAILABLE:
            tests.append(CommandTest(
                name="Handler Initialization",
                category="Core",
                command="status",
                expected_output_contains=["RADICAL SEA BUNNY"]
            ))
            
            tests.append(CommandTest(
                name="Help Command",
                category="Core",
                command="help",
                expected_output_contains=["Commands", "RADICAL SEA BUNNY"]
            ))
        
        return tests
    
    def run_all_tests(self):
        """Run all command tests"""
        self.print_header()
        
        tests = self.get_command_tests()
        print(f"{Colors.BOLD}🏃 Running {len(tests)} tests...{Colors.RESET}\n")
        
        # Group by category
        categories = {}
        for test in tests:
            if test.category not in categories:
                categories[test.category] = []
            categories[test.category].append(test)
        
        # Run tests by category
        for category, category_tests in categories.items():
            print(f"\n{Colors.BOLD}{Colors.BLUE}📁 Category: {category}{Colors.RESET}")
            
            for test in category_tests:
                result = self.run_command_test(test)
                self.results.append(result)
                self.print_result(result)
        
        # Print summary
        self.print_summary()
        
        # Save report
        self.save_report()
    
    def save_report(self, filename: str = "test_results.json"):
        """Save test results to JSON file"""
        report_path = Path("test_reports")
        report_path.mkdir(exist_ok=True)
        
        report = {
            "timestamp": self.start_time.isoformat(),
            "duration": (datetime.now() - self.start_time).total_seconds(),
            "total_tests": len(self.results),
            "passed": sum(1 for r in self.results if r.passed),
            "failed": sum(1 for r in self.results if not r.passed),
            "results": [
                {
                    "name": r.name,
                    "category": r.category,
                    "passed": r.passed,
                    "message": r.message,
                    "duration": r.duration,
                    "details": r.details
                }
                for r in self.results
            ]
        }
        
        filepath = report_path / filename
        with open(filepath, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n{Colors.BLUE}📄 Test report saved to: {filepath}{Colors.RESET}")
    
    def test_specific_command(self, command: str):
        """Test a specific command"""
        print(f"\n{Colors.BOLD}🔍 Testing command: {Colors.CYAN}{command}{Colors.RESET}")
        
        test = CommandTest(
            name=f"Command: {command}",
            category="Custom",
            command=command,
            expected_success=True
        )
        
        result = self.run_command_test(test)
        self.results.append(result)
        self.print_result(result)
        
        return result.passed

def main():
    """Main execution"""
    try:
        # Check if specific command is provided
        if len(sys.argv) > 1:
            command = ' '.join(sys.argv[1:])
            tester = CommandTester()
            tester.test_specific_command(command)
            
            # Show summary
            print(f"\n{Colors.BOLD}📊 Test Summary:{Colors.RESET}")
            passed = sum(1 for r in tester.results if r.passed)
            total = len(tester.results)
            print(f"  Tests: {total}")
            print(f"  {Colors.GREEN}✅ Passed: {passed}{Colors.RESET}")
            print(f"  {Colors.RED}❌ Failed: {total - passed}{Colors.RESET}")
            sys.exit(0 if passed == total else 1)
        
        # Run all tests
        tester = CommandTester()
        
        # Check if modules are available
        print(f"{Colors.BOLD}🔍 Checking RADICAL SEA BUNNY availability...{Colors.RESET}")
        if MODULES_AVAILABLE:
            print(f"{Colors.GREEN}✅ RADICAL SEA BUNNY modules loaded successfully{Colors.RESET}")
        else:
            print(f"{Colors.YELLOW}⚠️ Running in standalone mode (limited testing){Colors.RESET}")
            print(f"{Colors.YELLOW}   Install RADICAL SEA BUNNY for full testing{Colors.RESET}")
        
        tester.run_all_tests()
        
        # Exit with appropriate code
        passed = sum(1 for r in tester.results if r.passed)
        total = len(tester.results)
        sys.exit(0 if passed == total else 1)
        
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}⚠️ Test suite interrupted by user{Colors.RESET}")
        sys.exit(1)
    except Exception as e:
        print(f"\n{Colors.RED}❌ Error during testing: {e}{Colors.RESET}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    # Try to import shutil for which function
    try:
        import shutil
    except ImportError:
        # Define simple which function
        def which(cmd):
            import os
            for path in os.environ["PATH"].split(os.pathsep):
                exe = os.path.join(path, cmd)
                if os.path.exists(exe):
                    return exe
                if os.name == 'nt' and not exe.endswith('.exe'):
                    exe_exe = exe + '.exe'
                    if os.path.exists(exe_exe):
                        return exe_exe
            return None
        shutil.which = which
    
    main()